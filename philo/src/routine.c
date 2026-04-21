/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   routine.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 16:30:58 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/21 09:39:52 by fyagbasa         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

static void	helper1(t_person *person)
{
	pthread_mutex_lock(person->r_hand);
	print_status(person, "has taken a fork");
	pthread_mutex_lock(&person->philo->statemutex);
	person->last_eat = get_time();
	person->eat_count++;
	pthread_mutex_unlock(&person->philo->statemutex);
	print_status(person, "is eating");
	usleep(person->philo->tte * 1000);
	pthread_mutex_unlock(person->l_hand);
	pthread_mutex_unlock(person->r_hand);
}

static void	helper2(t_person *person)
{
	int	think_time;

	print_status(person, "is sleeping");
	usleep(person->philo->tts * 1000);
	print_status(person, "is thinking");
	if (person->philo->nop % 2 != 0)
	{
		think_time = person->philo->tte - person->philo->tts;
		if (think_time < 0)
			think_time = 0;
		usleep((think_time * 1000) + 5000);
	}
}

static void	lock_state(t_person *person)
{
	pthread_mutex_lock(&person->philo->statemutex);
	person->last_eat = get_time();
	pthread_mutex_unlock(&person->philo->statemutex);
	if (person->id % 2 == 0)
		usleep((person->philo->tte * 1000) / 2);
}

static int	stop_check(t_person *person)
{
	pthread_mutex_lock(&person->philo->statemutex);
	if (person->philo->is_dead == 1)
	{
		pthread_mutex_unlock(&person->philo->statemutex);
		return (1);
	}
	if (person->philo->loop_count != -1
		&& person->eat_count == person->philo->loop_count)
	{
		pthread_mutex_unlock(&person->philo->statemutex);
		return (1);
	}
	pthread_mutex_unlock(&person->philo->statemutex);
	return (0);
}

void	*routine(void *arg)
{
	t_person	*person;

	person = (t_person *)arg;
	lock_state(person);
	while (!stop_check(person))
	{
		pthread_mutex_lock(person->l_hand);
		print_status(person, "has taken a fork");
		if (person->philo->nop == 1)
		{
			usleep(person->philo->ttd * 1000);
			pthread_mutex_unlock(person->l_hand);
			break ;
		}
		helper1(person);
		if (stop_check(person))
			break ;
		helper2(person);
	}
	return (NULL);
}
