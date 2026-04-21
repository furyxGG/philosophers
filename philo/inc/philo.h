/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   philo.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 14:55:12 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/20 01:07:11 by fyagbasa         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PHILO_H
# define PHILO_H

# include <pthread.h>
# include <stdio.h>
# include <unistd.h>
# include <stdlib.h>
# include <sys/time.h>

typedef struct s_philo	t_philo;
typedef struct s_person	t_person;
typedef struct s_person
{
	int				id;
	int				eat_count;
	long long		last_eat;
	pthread_t		thread;
	pthread_mutex_t	*r_hand;
	pthread_mutex_t	*l_hand;
	t_philo			*philo;
}				t_person;

typedef struct s_philo
{
	int				nop;
	int				ttd;
	int				tte;
	int				tts;
	int				loop_count;
	int				is_dead;
	t_person		*persons;
	pthread_mutex_t	*forks;
	pthread_mutex_t	printmutex;
	pthread_mutex_t	statemutex;
}				t_philo;

int			ft_atoi(const char *nptr);
int			ft_isdigit(int c);
int			ft_strlen(char *str);
long long	get_time(void);
void		print_status(t_person *person, char *status);

void		*routine(void *arg);
void		monitor(t_philo *philo);
void		create_allthings(t_philo *philo);

#endif