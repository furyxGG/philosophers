/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_atoi.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 15:05:24 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/19 21:03:27 by fyagbasa         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

int	ft_atoi(const char *nptr)
{
	int	total;
	int	sign;

	total = 0;
	sign = 1;
	while ((*nptr >= 9 && *nptr <= 13) || *nptr == ' ')
		nptr++;
	if (*nptr == '+' || *nptr == '-')
	{
		if (*nptr == '-')
			sign = sign * -1;
		nptr++;
	}
	while (*nptr >= 48 && *nptr <= 57)
	{
		total = total * 10 + (*nptr - '0');
		nptr++;
	}
	return (total * sign);
}

void	ft_usleep(long long time_in_ms, t_person *person)
{
	long long	start;

	start = get_time();
	while ((get_time() - start) < time_in_ms)
	{
		pthread_mutex_lock(&person->philo->statemutex);
		if (person->philo->is_dead == 1)
		{
			pthread_mutex_unlock(&person->philo->statemutex);
			break ;
		}
		pthread_mutex_unlock(&person->philo->statemutex);
		usleep(500);
	}
}
