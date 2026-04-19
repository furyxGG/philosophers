/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   monitor.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 20:27:56 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/20 00:26:23 by fyagbasa         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

static void	helper(t_philo *philo, int a)
{
	pthread_mutex_lock(&philo->printmutex);
	printf("%lld %d died\n", get_time(), philo->persons[a].id);
	philo->is_dead = 1;
	pthread_mutex_unlock(&philo->printmutex);
}

void	monitor(t_philo *philo)
{
	int	all_eat;
	int	a;

	all_eat = 0;
	while (1)
	{
		a = 0;
		while (a < philo->nop)
		{
			if (get_time() - philo->persons[a].last_eat >= philo->ttd)
			{
				helper(philo, a);
				return ;
			}
			if (philo->loop_count != -1
				&& philo->persons[a].eat_count == philo->loop_count)
				all_eat++;
			a++;
		}
		if (all_eat == philo->nop)
		{
			philo->is_dead = 1;
			return ;
		}
	}
}
