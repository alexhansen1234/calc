#ifndef ECON_HW_H
#define ECON_HW_H

#include <math.h>

#define max(x, y) (x > y ? x : y)
#define min(x, y) (x > y ? y : x)

double newton(double (* func)(double, double), double a, double b)
{
	double delta = 0.00001;
	double temp, fx, dfx;
	int max_iter=500;
	while(max_iter-- > 0)
	{
		fx = func(a, b);
		dfx = (func(a + delta, b) - fx)/delta;

		temp = a - fx/dfx;

		if(fabs(temp-a) < delta)
			break;

		a = temp;
	}

	return temp;
}

double f_p(double ir, double n)
{
	return pow((1.0 + ir), n);
}

double p_f(double ir, double n)
{
	return 1.0 / f_p(ir, n);
}

double f_a(double ir, double n)
{
	return ( pow((1.0 + ir), n) - 1.0) / ir;
}

double a_f(double ir, double n)
{
	return 1.0 / f_a(ir, n);
}

double a_p(double ir, double n)
{
	return a_f(ir, n) * f_p(ir, n);
}

double p_a(double ir, double n)
{
	return 1.0 / a_p(ir, n);
}

double a_g(double ir, double n)
{
	return (1.0/ir - n / (pow(1.0 + ir, n) - 1));
}

double p_g(double ir, double n)
{
	return a_g(ir, n) * p_a(ir, n);
}

double p_a_geo(double ir, double n, double g)
{
	if(ir == g)
	{
		return n / (1.0 + ir);
	}
	else
	{
		return (1 - pow( 1.0 + g, n )*pow( 1.0 + ir , -n))/(ir - g);
	}
}

double nper(double amount, double payment, double ir)
{
	double n = 1.0;
	double temp;
	double delta = 0.000001;
	double fx, dfx;

	for(int i=0; ; i++)
	{
		fx = amount - payment * p_a(ir, n);
		dfx = ((amount - payment * p_a(ir, n + delta)) - fx) / delta;

		temp = n - fx/dfx;

		if(fabs(temp - n) < delta)
		{
			break;
		}

		n = temp;
	}

	return temp;
}

double round_lf(double val, int places)
{
        return ((double)(((long)((val * pow(10.0, places+1 )+5)))/10)) / pow(10.0, places);
}

double round_money(double val)
{
        return round_lf(val, 2); 
}

void amortization_table(double initial_balance, double eff_ir, int n)
{
        double previous_balance = initial_balance;
        double interest;
        double payment = round_money( initial_balance * a_p(eff_ir, n) );
        printf("Initial Balance = %lf\n", initial_balance);
        printf("Interest Rate = %lf\n", eff_ir);
        printf("N = %d\n", n); 
        printf("Payment = %lf\n", payment);
        printf("\n");
        printf("\t\t\tPrincipal\tEnding\n");
        printf("Time\tInterest\tPayment\t\tBalance\n");
    
        for(int i=0; i < n+1; i++)
        {   
                interest = round_money((i == 0 ? 0.0 : eff_ir * previous_balance));
                previous_balance -= round_money((i == 0 ? 0: payment - interest));
                printf("%d\t%lf\t%lf\t%lf\n", i, interest, payment - interest, previous_balance);
        }   
}

double ror(double p, double a, double g, double f, double n)
{
    double _fx(double i)
    {
        return p + a*p_a(i, n) +  g*p_g(i, n) + f*p_f(i, n);
    }

    double delta=0.00001;
    double fx, dfx, temp=0.5;
    double rate = 0.5;
    int max_iter=50;

    while(max_iter--)
    {
        printf("temp = %lf\n", temp);
        fx = _fx(rate);
        dfx = (_fx(rate+delta)-fx);
        temp = rate - fx/dfx*delta;
        if(fabs(temp-rate)<delta)
            break;
        rate=temp;
    }

    return temp;
}

#endif
