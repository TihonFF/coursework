#include <cstdio>
#include <cstdlib>
#include <pthread.h>
#include <unistd.h>
#include <time.h>
#include <mpi.h>
#include <bits/stdc++.h>

using namespace std;

int main(int argc, char *argv[])
{
    int rank, numProc;
    double time0, time1, time2, dtime, maxtime, mintime, midtime;

    int i, j, k, rows, offset;
    MPI_Status status;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &numProc);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    int N = 0;
    if (rank == 0) {
        if (argc < 2) {
            printf("Использование: mpirun -np <procs> %s <N>\n", argv[0]);
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
        N = atoi(argv[1]);
    }

    // Рассылаем N всем процессам
    MPI_Bcast(&N, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if (N % numProc != 0) {
        if (rank == 0)
            printf("Ошибка: N (%d) должно делиться на numProc (%d)\n", N, numProc);
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    rows = N / numProc;

    // === ДИНАМИЧЕСКОЕ ВЫДЕЛЕНИЕ ПАМЯТИ ===
    double *matA = new double[N * N];
    double *matB = new double[N * N];
    double *matC = new double[N * N];

    // Локальные буферы для приёма/отправки
    double *localA = new double[rows * N];
    double *localC = new double[rows * N];

    if (rank == 0) {
        // Инициализация матриц A и B
        srand(time(0));
        for (i = 0; i < N; i++) {
            for (j = 0; j < N; j++) {
                matA[i * N + j] = rand() % 10;
                matB[i * N + j] = rand() % 10;
            }
        }
    }

    time0 = MPI_Wtime();

    // Рассылка матрицы B всем
    MPI_Bcast(matB, N * N, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    time1 = MPI_Wtime();

    if (rank == 0) {
        offset = rows;
        // Рассылка частей A
        for (int dest = 1; dest < numProc; dest++) {
            MPI_Send(&offset, 1, MPI_INT, dest, 1, MPI_COMM_WORLD);
            MPI_Send(&matA[offset * N], rows * N, MPI_DOUBLE, dest, 1, MPI_COMM_WORLD);
            offset += rows;
        }

        // Вычисления в master
        for (k = 0; k < N; k++) {
            for (i = 0; i < rows; i++) {
                double sum = 0.0;
                for (j = 0; j < N; j++) {
                    sum += matA[i * N + j] * matB[j * N + k];
                }
                matC[i * N + k] = sum;
            }
        }

        // Приём результатов
        for (int src = 1; src < numProc; src++) {
            MPI_Recv(&offset, 1, MPI_INT, src, 2, MPI_COMM_WORLD, &status);
            MPI_Recv(&matC[offset * N], rows * N, MPI_DOUBLE, src, 2, MPI_COMM_WORLD, &status);
        }
    } else {
        // Приём задания
        MPI_Recv(&offset, 1, MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
        MPI_Recv(localA, rows * N, MPI_DOUBLE, 0, 1, MPI_COMM_WORLD, &status);

        // Локальные вычисления
        for (k = 0; k < N; k++) {
            for (i = 0; i < rows; i++) {
                double sum = 0.0;
                for (j = 0; j < N; j++) {
                    sum += localA[i * N + j] * matB[j * N + k];
                }
                localC[i * N + k] = sum;
            }
        }

        // Отправка результата
        MPI_Send(&offset, 1, MPI_INT, 0, 2, MPI_COMM_WORLD);
        MPI_Send(localC, rows * N, MPI_DOUBLE, 0, 2, MPI_COMM_WORLD);
    }

    time2 = MPI_Wtime();
    dtime = time2 - time1;

    // Сбор статистики
    MPI_Reduce(&dtime, &maxtime, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
    MPI_Reduce(&dtime, &mintime, 1, MPI_DOUBLE, MPI_MIN, 0, MPI_COMM_WORLD);
    MPI_Reduce(&dtime, &midtime, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        midtime /= numProc;
        long long matrix_bytes = (long long)N * N * sizeof(double);
        printf("Размер матрицы = %lld (байт)\n", matrix_bytes);
        printf("Время Bcast = %.6f (сек.)\n", time1 - time0);
        printf("Время вычислений: Мин.=%.6f; Макс.=%.6f; Среднее=%.6f (сек.)\n",
               mintime, maxtime, midtime);
    }

    // Освобождение памяти
    delete[] matA;
    delete[] matB;
    delete[] matC;
    delete[] localA;
    delete[] localC;

    MPI_Finalize();
    return 0;
}