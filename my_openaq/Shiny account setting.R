library(rsconnect)

name='edanesh'
token='246619465AD1477BE95E0B67161099CB'
secret='Ck4IIoOKQhg7eKY0mavk4D/exvp/FLGwCxN1eqsb'

options(rsconnect.http.trace = TRUE, rsconnect.error.trace = TRUE, rsconnect.http.verbose = TRUE)
rsconnect::setAccountInfo(name,
                          token,
                          secret)
