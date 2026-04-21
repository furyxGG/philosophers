/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   monitor.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 20:27:56 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/21 09:40:04 by fyagbasa         ###   ########.tr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

static void	helper(t_philo *philo, int a)
{
	pthread_mutex_lock(&philo->printmutex);
	printf("%lld %d died\n", get_time()
		- philo->start_time, philo->persons[a].id);
	philo->is_dead = 1;
	pthread_mutex_unlock(&philo->printmutex);
}

static int	check_status(t_philo *philo)
{
	int	all_eat;
	int	a;

	a = -1;
	all_eat = 0;
	while (++a < philo->nop)
	{
		pthread_mutex_lock(&philo->statemutex);
		if (philo->loop_count != -1
			&& philo->persons[a].eat_count == philo->loop_count)
			all_eat++;
		else if (get_time() - philo->persons[a].last_eat >= philo->ttd)
		{
			helper(philo, a);
			pthread_mutex_unlock(&philo->statemutex);
			return (1);
		}
		pthread_mutex_unlock(&philo->statemutex);
	}
	if (all_eat == philo->nop)
		return (2);
	return (0);
}

void	monitor(t_philo *philo)
{
	int	status;

	while (1)
	{
		status = check_status(philo);
		if (status == 1)
			return ;
		if (status == 2)
		{
			pthread_mutex_lock(&philo->statemutex);
			philo->is_dead = 1;
			pthread_mutex_unlock(&philo->statemutex);
			return ;
		}
		usleep(1000);
	}
}
