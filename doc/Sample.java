package org.crsx.hacs.samples;
public class Sample {
	
	public abstract static class Fun<A, R> {
		abstract public R ap(A arg_1);
	}

	public static void main(String[] args) {
		System.out.println(
				new Fun<Fun<Double, Double>, Double>() {
					public Double ap(Fun<Double, Double> arg_3) {
						return arg_3.ap((double) 2);
					}
				}.ap(new Fun<Double, Double>() {
					public Double ap(Double arg_2) {
						return (arg_2 > 0.0 ? arg_2 : ((double) 0 - arg_2));
					}
				})
		);
	}
}
