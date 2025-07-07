#!/usr/bin/env python
# coding: utf-8

# In[9]:


# Deep-Dive & KPI Packaging in Python (pandas)

import pandas as pd

# Load clean data
df = pd.read_csv('/Users/davidsolis/Desktop/Portfolio Projects/Employee Attrition/hr_clean.csv')

# Compute Engagement Index
#  Weighted sum of satisfaction metrics (e.g. 40% env, 30% job, 30% life)
df['engagement_index'] = (
    0.4 * df['EnvironmentSatisfaction'] +
    0.3 * df['years_at_company'] +
    0.3 * df['overtime_flag']
)

# Calculate Replacement Cost Estimate
avg_salary = df['MonthlyIncome'].mean()
replacement_cost = (df['churn_flag'].sum() 
                    * avg_salary 
                    * 1.5)  # industry factor

# Identify High-Risk Segments DataFrame
high_risk = (
    df[df['overtime_flag'] == 1]
      .groupby('JobRole')
      .agg(attrition_rate=('churn_flag', 'mean'),
           headcount=('EmployeeNumber', 'count'))
      .query('headcount > 20')  # threshold for stability
      .sort_values('attrition_rate', ascending=False)
)

# Output core KPIs
kpis = {
    'Overall Churn Rate (%)': round(df['churn_flag'].mean() * 100, 2),
    'Avg Tenure Exited (yrs)': round(df.loc[df['churn_flag']==1, 'years_at_company'].mean(), 2),
    'Avg Tenure Retained (yrs)': round(df.loc[df['churn_flag']==0, 'years_at_company'].mean(), 2),
    'Avg Income Exited ($)': round(df.loc[df['churn_flag']==1, 'MonthlyIncome'].mean(), 2),
    'Avg Income Retained ($)': round(df.loc[df['churn_flag']==0, 'MonthlyIncome'].mean(), 2),
    'Replacement Cost Estimate ($)': round(replacement_cost, 0),
    'Avg Engagement Index': round(df['engagement_index'].mean(), 2),
}
print(pd.Series(kpis))
print("\nHigh-Risk Roles (Overtime Attrition):")
print(high_risk.head(10))


# In[ ]:




