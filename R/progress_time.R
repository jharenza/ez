progress_time = function () 
{
	n <- 0
	bar <- NULL
	list(
		init = function(max) {
			min = 0
			initial = 0
			.start <- proc.time()[3]
			.last_update_time <- .start
			.times <- NULL
			.val <- initial
			.last_val <- 0
			.killed <- FALSE
			.nb <- 0L
			.pc <- 0L
			width <- getOption("width")
			width <- width - nchar('||100%  ~ 999.9 h remaining.')
			width <- trunc(width)
			if (max <= min){
				stop("must have max > min")
			}
			msg = paste(
				c(
					"\r|"
					, rep.int(" ", width)
					, "|  0%"
				)
				, collapse = ''
			)
			cat(paste(msg,rep(' ',max(c(0,trunc(getOption("width")-nchar(msg))))),'\r'))
			flush.console()
			getVal <- function() .val
			up <- function(value){
				if (!is.finite(value) || value < min || value > max){
					return()
				}
				.val <<- value
				minutes = TRUE
				nb <- round(width * (value - min)/(max - min))
				pc <- round(100 * (value - min)/(max - min))
				if (nb == .nb && pc == .pc){ 
					return()
				}
				.nb <<- nb
				.pc <<- pc
				now = proc.time()[3]
				time_since_last_update = now - .last_update_time
				.last_update_time <<- now
				.times <<- c(.times,(time_since_last_update)/(.val-.last_val))
				time_left = round((max-value)*mean(.times),0)
				unit = ' s'
				if(time_left>60){
					time_left = round((max-value)*mean(.times)/60,0)
					unit = ' m'
					if(time_left>60){
						time_left = round((max-value)*mean(.times)/60/60,1)
						unit = ' h'
					}
				}
				msg = paste(
					c(
						"\r|"
						, rep.int('=', nb)
						, rep.int(" ", (width - nb))
						, sprintf("|%3d%%", pc)
						, '  ~ '
						, time_left
						, unit
						, ' remaining.'
					)
					, collapse = ''
				)
				cat(paste(msg,rep(' ',max(c(0,trunc(getOption("width")-nchar(msg))))),'\r'))
				flush.console()
				.last_val <<- .val
			}
			kill <- function(){
				if (!.killed) {
					if(.pc == 100){
						msg = paste(
							c(
								"\r|"
								, rep.int('=', .nb)
								, rep.int(" ", (width - .nb))
								, "|100%"
							)
							, collapse = ''
						)
						cat(paste(msg,rep(' ',max(c(0,trunc(getOption("width")-nchar(msg))))),'\r'))
						msg = paste('Completed after',round(proc.time()[3]-.start),'seconds.')
					}else{
						msg = paste('Killed after',round(proc.time()[3]-.start),'seconds.')
					}
					cat(paste('\n',msg,'\n'))
					.killed <<- TRUE
				}
			}
			bar<<-structure(list(getVal = getVal, up = up, kill = kill), class = "txtProgressBar")
		}
		, step = function() {
			n <<- n + 1
			bar$up(n)
		}
		, term = function() close(bar)
	)
}

