
`%+%` <- function(l, r) {
  paste0(as.character(l), as.character(r))
}

#' @importFrom crayon col_substring

repeat_string <- function(str, len) {
  stopifnot(length(str) == 1)
  character(max(len) + 1) %>%
    paste(collapse = str) %>%
    col_substring(1, len)
}

#' @importFrom crayon col_nchar

pad_right <- function(str, max, chr = " ") {
  str <- as.character(str)
  length <- max - col_nchar(str)
  ifelse(length <= 0, str, str %+% repeat_string(chr, length))
}

#' @importFrom crayon col_nchar

pad_center <- function(str, max, chr = " ") {
  str <- as.character(str)
  length <- max - col_nchar(str)
  ifelse(length <= 0, str, repeat_string(chr, floor(length / 2)) %+% str %+%
           repeat_string(chr, length - floor(length / 2)))
}

#' @importFrom crayon col_nchar

pad_left <- function(str, max, chr = " ") {
  str <- as.character(str)
  length <- max - col_nchar(str)
  ifelse(length <= 0, str, repeat_string(chr, length) %+% str)
}

pad <- function(str, max, chr = " ", align = c("left", "center", "right")) {
  align <- match.arg(align)
  if (align == "left") {
    pad_right(str, max, chr)
  } else if (align == "center") {
    pad_center(str, max, chr)
  } else if (align == "right") {
    pad_left(str, max, chr)
  }
}

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#' @importFrom crayon col_nchar

split_into_lines_1 <- function(str, max) {
  split_into_lines_line <- function(str) {
    words <- str %>%
      trim() %>%
      strsplit(" ") %>%
      `[[`(1)
    lines <- list()
    line <- words[1]
    for (w in words[-1]) {
      if (col_nchar(paste(line, collapse = " ")) + col_nchar(w) < max) {
        line <- c(line, w)
      } else {
        lines <- c(lines, list(line))
        line <- w
      }
    }
    if (length(line)) lines <- c(lines, list(line))
    vapply(lines, paste, "", collapse = " ", USE.NAMES = FALSE)
  }
  str %>%
    strsplit("\n") %>%
    `[[`(1) %>%
    lapply(split_into_lines_line) %>%
    unlist()
}

split_into_lines <- function(str, max) {
  lapply(str, split_into_lines_1, max = max)
}

#' @importFrom crayon col_strsplit col_substring

split_long_words <- function(str, max, truncation_chr = "-") {

  break_word <- function(word) {
    nc <- col_nchar(word)
    if (nc <= max) return(word)
    break_points <- seq(1, nc, by = max - 1)
    res <- col_substring(word, break_points, break_points + max - 1 - 1)
    if (length(res) == 1) {
      res
    } else {
      res[1:(length(res)-1)] <- paste(res[1:(length(res)-1)],
                                      truncation_chr, sep = "")
      res
    }
  }

  break_words <- function(words) {
    lapply(words, break_word) %>%
      unlist()
  }

  str %>%
    trim() %>%
    col_strsplit(split = " ") %>%
    lapply(break_words) %>%
    vapply(paste, collapse = " ", "")
}

#' @importFrom crayon col_substr

truncate_string <- function(str, max) {
  col_substr(str, 1, max)
}

do_call <- function (f, ..., .args = list(), .env = parent.frame()) {
  f <- substitute(f)
  call <- make_call(f, ..., .args)
  eval(call, .env)
}

make_call <- function (f, ..., .args = list()) {
  if (is.character(f))
    f <- as.name(f)
  as.call(c(f, ..., .args))
}
