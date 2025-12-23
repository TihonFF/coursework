#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <mpi.h>
#include <pthread.h>
#include <unistd.h>
#include <ctime>

#define SIZE 2000
// #define DEBUG

// a, b, с — указатели на массивы, индексы begin, end — какие элементы сложить
struct ThreadArg { 
    const int* a;
    const int* b;
    int* c;
    int begin;
    int end;
};

//  void* — универсальны указатель для pthread, (ThreadArg*)v; — приведение типа (универсальный указатель как указатель на ThreadArg),         ta->a[i] — разыменования указателя на структуру)
void* thread_func(void* v) {
    ThreadArg* ta = (ThreadArg*)v;
    for (int i = ta->begin; i <= ta->end; ++i) {
        ta->c[i] = ta->a[i] + ta->b[i];
    }
    return nullptr;
}
// get_block(номер тек процесса, сколько всего процессов MPI, общий размер массива, ссылка куда функция положит индекс начала блока, ссылка куда функция положит длину блока);
// Вычисляем начало и размер блока для процесса rank
void get_block(int rank, int nproc, long long N, int& start, int& size) {
    int base = N / nproc;
    int rem  = N % nproc;
    size = base + (rank < rem);
    start = (rank < rem) ? rank * (base + 1) : rem * (base + 1) + (rank - rem) * base;
}

int main(int argc, char** argv) {
    int rank, nproc;
//Инициализация MPI
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);
//Размер данных
    const long long N = SIZE;
//Получаем диапазон для данного процесса
    int local_start = 0, local_size = 0;
    get_block(rank, nproc, N, local_start, local_size);
//Создание массивов A, B, C только в процессе 0
    int *A = nullptr, *B = nullptr, *C = nullptr;
    if (rank == 0) {
        A = new int[N];
        B = new int[N];
        C = new int[N];
//Заполняем рандомными значениями
        srand(time(nullptr) + 12345);
        for (long long i = 0; i < N; ++i) {
            A[i] = rand() % 20;
            B[i] = rand() % 70;
        }
    }
//Локальные массивы для каждого процесса
    int* la = new int[local_size];
    int* lb = new int[local_size];
    int* lc = new int[local_size];

    // Рассылка данных MPI (если это мастер, то он рассылает данные)
    if (rank == 0) {
        for (int p = 0; p < nproc; ++p) {
            int p_start, p_size;
            get_block(p, nproc, N, p_start, p_size);
//Свой кусок мастер копирует себе
            if (p == 0) {
                memcpy(la, A + p_start, p_size * sizeof(int));
                memcpy(lb, B + p_start, p_size * sizeof(int));
//А остальным процессам отправляет
            } else {
                MPI_Send(A + p_start, p_size, MPI_INT, p, 1, MPI_COMM_WORLD);
                MPI_Send(B + p_start, p_size, MPI_INT, p, 2, MPI_COMM_WORLD);
            }
        }
//Если это рабочий процесс, то он получает данные
    } else {
        MPI_Recv(la, local_size, MPI_INT, 0, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        MPI_Recv(lb, local_size, MPI_INT, 0, 2, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }
//Запуск потоков pthreads (определение числа потоков)
    int nthreads = (int)sysconf(_SC_NPROCESSORS_ONLN);
    if (nthreads < 1) nthreads = 1;
//Создание массивов потоков и аргументов
    pthread_t* threads = new pthread_t[nthreads];
    ThreadArg* args = new ThreadArg[nthreads];
//Разбиение данных между потоками
    int base_per_thread = local_size / nthreads;
    int extra = local_size % nthreads;
//Цикл создания потоков
    for (int t = 0; t < nthreads; ++t) {
        args[t].a = la;
        args[t].b = lb;
        args[t].c = lc;

        args[t].begin = t * base_per_thread + (t < extra ? t : extra);
        args[t].end   = args[t].begin + base_per_thread + (t < extra ? 1 : 0) - 1;
//Последний поток точно заканчивает на local_size – 1;
        if (t == nthreads - 1) args[t].end = local_size - 1;
//Запуск 
        pthread_create(&threads[t], nullptr, thread_func, &args[t]);
    }
//Ожидание потоков
    for (int t = 0; t < nthreads; ++t) pthread_join(threads[t], nullptr);

    delete[] threads;
    delete[] args;

    // Сбор результатов (только в rank 0)
    if (rank == 0) {
        // Мастер копирует свою часть
        memcpy(C + local_start, lc, local_size * sizeof(int));
       // Мастер получает части от других процессов
        for (int p = 1; p < nproc; ++p) {
            int p_start, p_size;
            get_block(p, nproc, N, p_start, p_size);
            MPI_Recv(C + p_start, p_size, MPI_INT, p, 100 + p, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }
//Проверка результата
        bool ok = true;
        for (long long i = 0; i < N && ok; ++i) {
            if (C[i] != A[i] + B[i]) {
                ok = false;
                printf("ОШИБКА на позиции %lld: %d + %d = %d, получено %d\n",
                       i, A[i], B[i], A[i] + B[i], C[i]);
            }
        }
        printf("Проверка результата: %s\n", ok ? "OK" : "ОШИБКА!");

        delete[] A; delete[] B; delete[] C;
    } else {
        MPI_Send(lc, local_size, MPI_INT, 0, 100 + rank, MPI_COMM_WORLD);
    }

    delete[] la; delete[] lb; delete[] lc;

    if (rank == 0) {
        printf("Успешно завершено. Процессов MPI: %d, потоков на узле: %d\n", nproc, nthreads);
    }
//Очистка и завершение MPI
    MPI_Finalize();
    return 0;
}