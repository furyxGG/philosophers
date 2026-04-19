/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   philo.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 14:55:12 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/19 17:22:43 by fyagbasa         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PHILO
# define PHILO

# include <pthread.h>
# include <stdio.h>
# include <unistd.h>
# include <stdlib.h>

typedef struct	s_person
{
	int				id;
	int				eat_count;
	int				last_eat;
	pthread_t		thread;
	pthread_mutex_t	*r_hand;
	pthread_mutex_t	*l_hand;
}				t_person;

typedef struct	s_philo
{
	int				nop;
	int				ttd;
	int				tte;
	int				tts;
	int				loop_count;
	t_person		*persons;
	pthread_mutex_t	*forks;
}				t_philo;


int	ft_atoi(const char *nptr);
int	ft_isdigit(int c);
int	ft_strlen(char *str);

void	*routine(void *arg);
void	create_allthings(t_philo *philo);

#endif