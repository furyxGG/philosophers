/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 16:34:18 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/19 17:21:12 by fyagbasa         ###   ########.fr       */
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
		philo->persons[a].id = a;
		philo->persons[a].l_hand = &philo->forks[a];
		philo->persons[a].r_hand = &philo->forks[(a + 1) % philo->nop];
		philo->persons[a].eat_count = 0;
		a++;
	}
}

void	create_threads(t_philo *philo)
{
	int	a;

	a = 0;
	while (a < philo->nop)
	{
		pthread_create(&(philo->persons[a].thread), NULL, &routine, &philo->persons[a]);
		a++;
	}
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