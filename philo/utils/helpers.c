/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   helpers.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 15:27:49 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/20 01:45:14 by fyagbasa         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

int	ft_isdigit(int c)
{
	if (c >= '0' && c <= '9')
		return (1);
	return (0);
}

int	ft_strlen(char *str)
{
	int	a;

	a = 0;
	while (str[a])
		a++;
	return (a);
}

long long	get_time(void)
{
	struct timeval	timev;

	if (gettimeofday(&timev, NULL))
		return (-1);
	return ((timev.tv_sec * 1000) + (timev.tv_usec / 1000));
}

void	print_status(t_person *person, char *status)
{
	pthread_mutex_lock(&person->philo->statemutex);
	if (person->philo->is_dead == 0)
	{
		pthread_mutex_lock(&person->philo->printmutex);
		printf("%lld %d %s\n", get_time()
			- person->philo->start_time, person->id, status);
		pthread_mutex_unlock(&person->philo->printmutex);
	}
	pthread_mutex_unlock(&person->philo->statemutex);
}

int	check_null_phil(t_philo *philo)
{
	if (philo->nop == 0)
	{
		print_err("Error: There must be at least 1 philosopher.\n", 2);
		free (philo);
		return (0);
	}
	if (philo->loop_count == 0)
	{
		print_err("Error: There must be at least 1 philosopher.\n", 2);
		free (philo);
		return (0);
	}
	return (1);
}
