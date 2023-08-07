# Monetary Policy and the Wage Inflation Unemployment Tradeoff - Code

Inside this folder [Code](https://github.com/RicardoGabriel/Monetary-Policy-and-the-Wage-Inflation---Unemployment-Tradeoff/tree/main/Code) you can find all Stata 15 and MATLAB codes used to produce the figures and tables in the paper.

To run the codes, one need to set the appropriate path in the paths.do file and run the Master.do. The Master.do has all the necessary packages to be installed and a control panel where one can change settings such as: number of lags, horizon, confidence bands, and different asymetry tests. 

It calls the following do files:

	1. Data_Management.do with option (wage_out = 0) to include all observations. It produces the dataset for the descriptives analysis.

	2. Descriptives.do creates Table 1, Table A.2, Table A.3, and Table A.4

	3. Figure_1.do creates Figure 1 and all subfigures for Figure A.1

Then, for the main annual analysis:

	1. Data management with option (wage_out = 1) to exclude outliers. It produces the dataset for the main analysis.

	2. Figure_2.do creates Figures 2; A.2; A.3; A.4 

	3. First_Stage.do generates Table A.5 on the first stage of the trilemma IV and generates the instrument used in the main analysis.

	4. PM_BM produces Figures 3.a, 3.b, and A.6

	5. MP_IRFs_BM creates Figure 3.c

	6. MP_IRFs generates Figure A.5

	7. SD_BM.do with options (hf==10 and match==1) produces Figures 4 and A7 and Tables A.7 (matched 10 year sample)

	8. SD_BM_Rob produces Table A.9 when adding monetary policy dummies to Equation 5

	9. SD_BM.do with options (hf==15 and match==10) produces the robustness analysis presented in Figures A8 and Table A.8 (unmatched 15 year sample)

Then, for the quarterly analysis:

	1. Data_Management_Quarter.do with options (match == 1 and wage_out==1) collects data directly from FRED database and creates the .dta file to be used in this analysis

	2. First_Stage_Quarter.do generates Table A.6 on the first stage of the trilemma IV and generates the instrument used in the main analysis.

	3. PM_BM_Quarter produces Figures A.9 a) and A.9 b)

	4. MP_IRFs_BM_Quarter generates Figure A.9 c)

	5. SD_BM_Quarter creates Figures 5 and A.10 and Table A.10

Then, for Appendix C:
	
	1. NKWPC_slope.m produces the estimated micro founded NKWPC model and Figure C.1