NAME	= philo
CC		= cc
CFLAGS	= -Wall -Wextra -Werror -pthread -I inc

SRC_DIR	= src/
UTL_DIR	= utils/
OBJ_DIR	= obj/

SRCS	= $(SRC_DIR)main.c \
		  $(UTL_DIR)ft_atoi.c \
		  $(UTL_DIR)helpers.c \
		  $(SRC_DIR)routine.c \
		  $(SRC_DIR)init.c \
		  $(SRC_DIR)monitor.c

OBJS	= $(SRCS:%.c=$(OBJ_DIR)%.o)

all: $(NAME)

$(NAME): $(OBJS)
	@$(CC) $(CFLAGS) $(OBJS) -o $(NAME)
	@echo "✨ $(NAME) succesfly compiled ✨"

$(OBJ_DIR)%.o: %.c
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@

clean:
	@rm -rf $(OBJ_DIR)
	@echo "🧹 .o files deleted"

fclean: clean
	@rm -f $(NAME)
	@echo "💣 $(NAME) deleted"

re: fclean all

.PHONY: all clean fclean re