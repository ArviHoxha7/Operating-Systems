#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include <sys/wait.h>
#include <semaphore.h>
#include <fcntl.h>
#include <time.h>
#include <string.h>

#define NUM_THREADS 4
#define LINES 100
#define NUMBERS_PER_LINE 50

sem_t *sem;
int total_sum = 0;
pthread_mutex_t sum_mutex;

void signal_handler(int sig) {
    char response;
    printf("\nReceived signal %d. Do you want to terminate the program? (y/n): ", sig);
    scanf(" %c", &response);
    if (response == 'y' || response == 'Y') {
        if (sem_close(sem) != 0) {
            perror("Failed to close semaphore");
            exit(1);
        }
        
        if (sem_unlink("/file_sem") != 0) {
            perror("Failed to unlink semaphore");
            exit(1);
        }
        exit(0);
    }
}

void process1() {
    FILE *file = fopen("data.txt", "w");
    if (file == NULL) {
        perror("Failed to open file");
        exit(1);
    }

    srand(time(NULL)); // Για τη δημιουργία τυχαίων αριθμών
    for (int i = 0; i < LINES; i++) {
        for (int j = 0; j < NUMBERS_PER_LINE; j++) {
            fprintf(file, "%d ", rand() % 101);
        }
        fprintf(file, "\n");
    }

    fclose(file);
    printf("File written successfully by Process 1\n");

    if (sem_post(sem) == -1) { // Απελευθερώνει το σημαφόρο για να ξεκινήσει η Process 2
        perror("sem_post failed");
        exit(1);
    }
}

void* thread_function(void *arg) {
    FILE *file = fopen("data.txt", "r");
    if (file == NULL) {
        perror("Failed to open file");
        exit(1);
    }

    int thread_id = *(int*)arg;
    int sum = 0, number;
    int line_count = 0;
    char line[1024];

    // Κάθε νήμα διαβάζει τη γραμμή που του αντιστοιχεί
    for (int i = 0; i < LINES; i++) {
        if (i % NUM_THREADS == thread_id) {
            fgets(line, sizeof(line), file);
            line_count++;
            char *token = strtok(line, " ");
            while (token != NULL) {
                number = atoi(token);
                sum += number;
                token = strtok(NULL, " ");
            }
        }
    }

    pthread_mutex_lock(&sum_mutex);
    total_sum += sum;
    pthread_mutex_unlock(&sum_mutex);

    printf("Thread %d processed %d lines. Local sum: %d\n", thread_id, line_count, sum);
    fclose(file);
    return NULL;
}

void process2() {
    pthread_t threads[NUM_THREADS];
    int thread_ids[NUM_THREADS];

    if (sem_wait(sem) == -1) { // Περιμένει να τελειώσει η Process 1
        perror("sem_wait failed");
        exit(1);
    }

    // Δημιουργία των νημάτων
    for (int i = 0; i < NUM_THREADS; i++) {
        thread_ids[i] = i;
        pthread_create(&threads[i], NULL, thread_function, (void*)&thread_ids[i]);
    }

    // Αναμονή για όλα τα νήματα
    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    printf("Total sum of all numbers: %d\n", total_sum);
}

int main() {
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    // Δημιουργία σημαφόρου
    sem = sem_open("/file_sem", O_CREAT, 0644, 0);
    if (sem == SEM_FAILED) {
        perror("Failed to create semaphore");
        exit(1);
    }
    if (pthread_mutex_init(&sum_mutex, NULL) != 0) {
        perror("Failed to initialize mutex");
        exit(1);
    }
    pid_t pid = fork();
    if (pid < 0) {
        perror("Failed to fork");
        exit(1);
    } else if (pid == 0) {
        process1();
        exit(1);
    } else {
        process2();
        if (waitpid(pid, NULL, 0) < 0) {
            perror("Failed to wait for child process");
            exit(1);
        }
    }
    if (sem_close(sem) != 0) {
        perror("Failed to close semaphore");
        exit(1);
    }
    if (sem_unlink("/file_sem") != 0) {
        perror("Failed to unlink semaphore!");
        exit(1);
    }
    if (pthread_mutex_destroy(&sum_mutex) != 0) {
        perror("Failed to destroy mutex");
        exit(1);
    }
    return 0;
}
