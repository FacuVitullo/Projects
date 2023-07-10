#!/usr/bin/env python
# coding: utf-8

# In[2]:


# Import the libraries.
import pandas as pd
import seaborn as sns
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
plt.style.use("ggplot")
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams["figure.figsize"] = (12, 8) #adjust the parameters for the plots.


# In[3]:


#Read in the data.

df = pd.read_csv("movies.csv")


# In[4]:


# Let's look at the data.
df.head()


# In[5]:


#Let's see if we have missing data, we can do that with a loop.

for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print("{}-{}%".format(col, pct_missing))


# In[6]:


#Let's look at the datatypes of our colums:
df.dtypes


# In[ ]:


#Float may not be ideal because we mostly have .0 in the end of our data, but we need to have float64 so we can use some functions latter.


# In[17]:


# Some of the values in the column year are different than the ones in the released column.
# That may be because movies are stored for some time before being released, so, while that data may be incorrect
# We would want to have the same value in both tables
# We ccan't remove the data assuming that these are mistakes, so we leave it as it is.


# df["year_release"] = df["released"].astype(string).str[0:4]


# In[7]:


# Let's see the gross revenue for these movies.
df.sort_values(by=["gross"], inplace = False, ascending = False )


# In[8]:


# We want to study the gross revenue and relations with other tables, so the ones with Not a Number
# Should be removed, because these don't have relevant information for our project.
df = df[np.isfinite(df["gross"])]
    


# In[9]:


df.sort_values(by=["gross"], inplace = False, ascending = False )


# In[9]:


#We also need to know the buget if we can, so we remove the NaN values from that column:
df = df[np.isfinite(df["budget"])]
df.sort_values(by=["gross"], inplace = False, ascending = False )


# In[10]:


# We want to study correlations with the gross revenue.
# We assume the columns we need to look to are the budget and the company.
# Let's do a plot of budget vs gross revenue.

plt.scatter(x = df["budget"], y = df["gross"])
plt.title("Budget VS. Gross Revenue")
plt.xlabel("Budget (in millions)")
plt.ylabel("Revenue (in millions)")
plt.show()


# In[11]:


#Plot the budget vs gross, this time using seaborn.
sns.regplot(x = "budget", y= "gross", data  = df, scatter_kws = {"color" : "red"}, line_kws = {"color" : "blue"})


# In[12]:


#Let's look at correlations.
df.corr(method  = "spearman") #pearson (default), kendall, spearman
#correlations closer to 1 mean that we may have some kind of linear relation between two values.
# Here we can see two interesting correlations, "gross and budget" and "gross and votes"


# In[16]:


correlation_matrix = df.corr()
sns.heatmap(correlation_matrix, annot = True) #Annot = True is used so the correlation value appears in the graph.

plt.title("Correlation matrix")
plt.show()




# In[17]:


# Now we also would want to look correlations with the other columns.
# To do so, we numerize them.
df_numerized = df

for col_name in df_numerized:
    if (df_numerized[col_name].dtype == "object"):
        df_numerized[col_name] =  df_numerized[col_name].astype("category")
        df_numerized[col_name] = df_numerized[col_name].cat.codes

        
df_numerized


# In[18]:


#Now let's look at the correlation here
correlation_matrix_2 = df_numerized.corr()
sns.heatmap(correlation_matrix, annot = True) #Annot = True is used so the correlation value appears in the graph.

plt.title("Correlation matrix")
plt.show()

#We know that there is a problem finding correlations because we can't quantify the "genre"
#There is not a comparable change between genre = 4 --> 5, and genre = 5 -->6
# While the numeric change is the same one, the actual change is not comparable.


# In[19]:


#Let's unstack that.
corr_pairs = correlation_matrix_2.unstack()
corr_pairs


# In[26]:


#Let's find the high correlations:
sorted_values = corr_pairs.sort_values() 
high_corr = sorted_values[(sorted_values) > 0.5]
high_corr


# In[ ]:




