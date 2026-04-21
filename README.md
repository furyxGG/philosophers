*This project has been created as part of the 42 curriculum by fyagbasa.*

# Description

This project is an implementation of the classic "Dining Philosophers" problem, a well-known exercise in concurrent programming and synchronization. The goal is to simulate a group of philosophers sitting at a table, alternating between thinking and eating, while sharing limited resources (forks) without causing deadlocks or starvation.

# Instructions

## Compilation
To compile the project, run the following command in the `philo` directory:

```zsh
make
```

## Execution
After compilation, execute the program with:

```zsh
./philo <number_of_philosophers> <time_to_die> <time_to_eat> <time_to_sleep> [number_of_times_each_philosopher_must_eat]
```

Example:
```zsh
./philo 5 800 200 200
```

- `<number_of_philosophers>`: Number of philosophers and forks
- `<time_to_die>`: Time (ms) before a philosopher dies if they don't start eating
- `<time_to_eat>`: Time (ms) a philosopher spends eating
- `<time_to_sleep>`: Time (ms) a philosopher spends sleeping
- `[number_of_times_each_philosopher_must_eat]`: (Optional) Simulation ends when each philosopher has eaten this many times

# Resources

- [Dining Philosophers Problem - Wikipedia](https://en.wikipedia.org/wiki/Dining_philosophers_problem)
- [POSIX Threads Programming](https://hpc-tutorials.llnl.gov/posix/#note-this-tutorial-is-no-longer-supported-it-remains-for-archival-purposes)

## Use of AI
AI was used to assist in the following specific tasks and parts of the project:
- **Concept Comprehension:** Learning and understanding the foundational mechanics of POSIX threads, mutexes, and concurrent programming concepts (like starvation and deadlocks) prior to and during implementation.
- **Debugging Multithreading Issues:** Analyzing ThreadSanitizer logs to identify and resolve data races and lock-order inversion in the `monitor.c` and `routine.c` logic.
- **Testing:** Creating an extensive automated bash script to run stress tests, check edge cases, and ensure memory safety across thousands of iterations.
- **Documentation:** Structuring and drafting this README file.

---