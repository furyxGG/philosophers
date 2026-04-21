/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 15:09:36 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/20 01:48:42 by fyagbasa         ###   ########.tr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

void	print_err(char *str, int i)
{
	int	a;

	a = 0;
	while (a < ft_strlen(str))
	{
		write(i, &str[a], 1);
		a++;
	}
}

static void	fill_philo(t_philo *m_philo, char **argv, int argc)
{
	m_philo->nop = ft_atoi(argv[1]);
	m_philo->ttd = ft_atoi(argv[2]);
	m_philo->tte = ft_atoi(argv[3]);
	m_philo->tts = ft_atoi(argv[4]);
	if (argc == 6)
		m_philo->loop_count = ft_atoi(argv[5]);
	else
		m_philo->loop_count = -1;
}

static int	check_argums(char **argv)
{
	int	a;
	int	b;
	int	flag;

	a = 1;
	flag = 0;
	while (argv[a])
	{
		b = 0;
		while (b < ft_strlen(argv[a]))
		{
			if (!ft_isdigit(argv[a][b]))
				flag = 1;
			b++;
		}
		a++;
	}
	if (flag)
		return (0);
	return (1);
}

static void	destroy_all(t_philo *philo)
{
	int	a;

	a = 0;
	while (a < philo->nop)
	{
		pthread_mutex_destroy(&philo->forks[a]);
		a++;
	}
	pthread_mutex_destroy(&philo->printmutex);
	if (philo->forks)
		free(philo->forks);
	if (philo->persons)
		free(philo->persons);
	free(philo);
}

int	main(int argc, char	**argv)
{
	t_philo	*m_philo;

	if (argc != 5 && argc != 6)
	{
		print_err("Error: Invalid number of arguments.\n", 2);
		return (-1);
	}
	if (!check_argums(argv))
	{
		print_err("Error: Arguments must be positive numbers.\n", 2);
		return (-1);
	}
	m_philo = malloc(sizeof(t_philo));
	if (!m_philo)
	{
		print_err("Error: Memory allocation failed.\n", 2);
		return (-1);
	}
	fill_philo(m_philo, argv, argc);
	if (!check_null_phil(m_philo))
		return (-1);
	create_allthings(m_philo);
	destroy_all(m_philo);
	return (0);
}
