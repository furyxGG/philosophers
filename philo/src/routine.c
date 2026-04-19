/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   routine.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 16:30:58 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/19 21:06:35 by fyagbasa         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

void	*routine(void *arg)
{
	t_person	*person;

	person = (t_person *)arg;
	if (person->id % 2 == 0)
		usleep(1000);
	while (1)
	{
		if (person->philo->is_dead == 1)
			break ;
		pthread_mutex_lock(person->l_hand);
		print_status(person, "has taken a fork");
		if (person->philo->nop == 1)
		{
			usleep(person->philo->ttd * 1000);
			pthread_mutex_unlock(person->l_hand);
			break ;
		}
		pthread_mutex_lock(person->r_hand);
		print_status(person, "has taken a fork");
		person->last_eat = get_time();
		print_status(person, "is eating");
		usleep(person->philo->tte * 1000);
		person->eat_count++;
		pthread_mutex_unlock(person->l_hand);
		pthread_mutex_unlock(person->r_hand);
		if (person->philo->loop_count != -1
			&& person->eat_count == person->philo->loop_count)
			break ;
		print_status(person, "is sleeping");
		usleep(person->philo->tts * 1000);
		print_status(person, "is thinking");
	}
	return (NULL);
}
