/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 16:34:18 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/20 01:07:29 by fyagbasa         ###   ########.tr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

static void	init_forks(t_philo *philo)
{
	int		a;

	a = 0;
	philo->forks = malloc(sizeof(pthread_mutex_t) * philo->nop);
	if (!philo->forks)
	{
		print_err("Error: Memory allocation failed for forks.\n", 2);
		return ;
	}
	while (a < philo->nop)
	{
		pthread_mutex_init(&philo->forks[a], NULL);
		a++;
	}
	pthread_mutex_init(&philo->printmutex, NULL);
	pthread_mutex_init(&philo->statemutex, NULL);
	philo->is_dead = 0;
}

static int	philo_init_helper(t_philo *philo)
{
	philo->persons = malloc(sizeof(t_person) * philo->nop);
	if (!philo->persons)
	{
		print_err("Error: Memory allocation failed for persons.\n", 2);
		return (0);
	}
	return (1);
}

static void	init_philos(t_philo *philo)
{
	int	a;

	a = 0;
	if (!philo_init_helper(philo))
		return ;
	while (a < philo->nop)
	{
		philo->persons[a].id = a + 1;
		if (a == philo->nop - 1)
		{
			philo->persons[a].l_hand = &philo->forks[(a + 1) % philo->nop];
			philo->persons[a].r_hand = &philo->forks[a];
		}
		else
		{
			philo->persons[a].l_hand = &philo->forks[a];
			philo->persons[a].r_hand = &philo->forks[(a + 1) % philo->nop];
		}
		philo->persons[a].eat_count = 0;
		philo->persons[a].philo = philo;
		philo->persons[a].last_eat = get_time();
		a++;
	}
}

static void	create_threads(t_philo *philo)
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
