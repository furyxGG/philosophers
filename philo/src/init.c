/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 16:34:18 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/19 21:04:19 by fyagbasa         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

void	init_forks(t_philo *philo)
{
	int		a;

	a = 0;
	philo->forks = malloc(sizeof(pthread_mutex_t) * philo->nop);
	while (a < philo->nop)
	{
		pthread_mutex_init(&philo->forks[a], NULL);
		a++;
	}
	pthread_mutex_init(&philo->printmutex, NULL);
	philo->is_dead = 0;
}

void	init_philos(t_philo *philo)
{
	int	a;

	a = 0;
	philo->persons = malloc(sizeof(t_person) * philo->nop);
	if (!philo->persons)
		return ;
	while (a < philo->nop)
	{
		philo->persons[a].id = a + 1;
		philo->persons[a].l_hand = &philo->forks[a];
		philo->persons[a].r_hand = &philo->forks[(a + 1) % philo->nop];
		philo->persons[a].eat_count = 0;
		philo->persons[a].philo = philo;
		philo->persons[a].last_eat = get_time();
		a++;
	}
}

void	create_threads(t_philo *philo)
{
	int	a;

	a = 0;
	while (a < philo->nop)
	{
		pthread_create(&(philo->persons[a].thread),
			NULL, &routine, &philo->persons[a]);
		a++;
	}
	monitor(philo);
	a = 0;
	while (a < philo->nop)
	{
		pthread_join(philo->persons[a].thread, NULL);
		a++;
	}
}

void	create_allthings(t_philo *philo)
{
	init_forks(philo);
	init_philos(philo);
	create_threads(philo);
}
