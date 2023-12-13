**SHAP-MODE**

Shapley Additive Explanations for Multi-objective Design Exploration (SHAP-MODE) is a MATLAB-based tool that accompanies the following publication:

*Palar, Pramudita Satria, Yohanes Bimo Dwianto, Lavi Rizki Zuhal, Joseph Morlier, Koji Shimoyama, Shigeru Obayashi. "Multi-Objective Design Space Exploration using Explainable Surrogate Models".*

The code comprises MATLAB-based tools to utilise Shapley values for enhancing knowledge discovery in multi-objective design space. The following utilities are available:
- Single-objective SHAP dependence plot.
- Multi-objective SHAP dependence plot.
- Summary SHAP plot
- SHAP correlation matrix

SHAP-MODE applies to any predictive model, including analytical functions, as SHAP itself is a model-agnostic method. For a swift introduction, you can explore the demonstration provided in 'demo_simple_fourbar_analytical.m', which directly computes SHAP from the analytical formulation of the four-bar truss function. The demonstration file will generate comprehensive information from SHAP, including the dependence plots. The "KERNEL_SHAP.m" file is the main subroutine to calculate SHAP values given the predictive model, the reference point, and the query point. Users are required to specify the predictive model as a function handle to be provided as input to "KERNEL_SHAP.m".

Alternatively, the 'shapley' subroutine from the MATLAB's statistics and machine learning toolbox can also be used to compute the SHAP values.

The airfoil problem demonstrations utilize the surrogate model built using UQLab. Therefore, installing UQLab is a prerequisite for running these demonstration files. The inviscid airfoil data can be found in 'Airfoil_Euler_data.mat', while the viscous airfoil data is accessible at 'Airfoil_Viscous_data.mat'. These files are respectively invoked by "SHAP_Airfoil_Euler.m" and "SHAP_Airfoil_viscous.m".

If you have questions, you can direct your questions to: pramsp@itb.ac.id

Pramudita Satria Palar
Assistant Professor
Faculty of Mechanical and Aerospace Engineering
Bandung Institute of Technology
Indonesia

Dependencies:
- UQlab (https://www.uqlab.com/)
- MATLAB's statistics and machine learning toolbox
