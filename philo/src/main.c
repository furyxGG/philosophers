/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: fyagbasa <fyagbasa@student.42istanbul.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/19 15:09:36 by fyagbasa          #+#    #+#             */
/*   Updated: 2026/04/19 21:07:00 by fyagbasa         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

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

int	main(int argc, char	**argv)
{
	t_philo	*m_philo;

	if (argc != 5 && argc != 6)
		return (-1);
	if (!check_argums(argv))
		return (-1);
	m_philo = malloc(sizeof(t_philo));
	if (!m_philo)
		return (-1);
	fill_philo(m_philo, argv, argc);
	create_allthings(m_philo);
}
