# Bellabeat Case Study Analysis 
#### by JanendraVian
#### September 20, 2023

## A. Introduction
Bellabeat is a high-tech manufacturer of health-focused products for women. Collecting data on activity, sleep, stress, and reproductive health has allowed Bellabeat to empower women with knowledge about their health and habits. Although Bellabeat is a successful small company, they have the potential to become a larger player in the global smart device market. Urška Sršen, co-founder and Chief Creative Officer of Bellabeat believes that analyzing smart device fitness data could help unlock new growth opportunities for the company.

## B. Scenario
Since it was founded in 2013, Bellabeat has grown rapidly and quickly positioned itself as a tech-driven wellness company for women. The company has 5 focus products: Bellabeat app, leaf, time, spring, and Bellabeat membership. Bellabeat is a successful small company, but they have the potential to become a more significant player in the global smart device market. Our team has been asked to analyze smart device data to understand how consumers use their smart devices. The insights we discover will then help guide the marketing strategy for the company.

## C. Tasks
### Guiding Questions
1. What are some trends in smart device usage?
2. How could these trends apply to Bellabeat customers?
3. How could these trends help influence BellaBeat's marketing strategy?

## Preparation
The dataset is available through this [FitBit Fitness Tracker Data](https://www.kaggle.com/datasets/arashnic/fitbit) (CC0: Public Domain, dataset made available through Mobius). This Kaggle data set contains a personal fitness tracker from thirty FitBit users. Thirty eligible FitBit users consented to the submission of personal tracker data, including minute-level output for physical activity, heart rate, and sleep monitoring. It includes information about daily activity, steps, and heart rate that can be used to explore users’ habits.
### ROCCC Analysis
| **ROCCC**      | **Analysis**  |
| ------------- |-------------  |
|  **Reliability**  | The data is from 30 eligible FitBit users who consented as participants. Even so, the reasons for how participants were chosen were not disclosed.  |
|  **Originality**  | The data was collected through Amazon Mechanical Turk and is available on Kaggle.  |
|  **Comprehensiveness**  |  The dataset includes activity, intensities, calories, steps, and heart rates and are recorded by the second, by the minute, by the hour, and daily although the data is from a small sample size of 30.  |
|  **Current**  |  The data is from 2016.  |
|  **Cited**  |  The data was collected from a third-party source.  |
### Data Limitation
- There are only 30 user data available, which is the minimum required for the central limit theorem's general rule of n≥30.
- Examining the datasets with ``` SELECT COUNT(DISTINCT Id) FROM ``` shows that there are 33 unique users for DailyActivity data, 24 for SleepDay data, and only 8 for WeightLog data. This indicates that there are 3 additional users in the dataset, and some users did not provide data for tracking DailyActivity and SleepDay.

## Process
There are 18 datasets available. The tables were then cleaned and transformed using a combination of Microsoft Excel and Microsoft SQL Server Management Studio. Three duplicates were found in the sleepDay_merged.csv file. The duplicates were then deleted. 

The date format from sleepDay_merged.csv and weightLogInfo_merged.csv were formatted incorrectly and some of the day and month were swapped, resulting in inconsistency. Both tables were cleaned and transformed in Excel. The incorrect columns were then transformed into text using the Text to Columns feature and converted into the date format using the formula as shown in the process below. The data then was reformatted into mm/dd/yyyy date format. The time both of the columns have been removed as time is irrelevant in this analysis.
|<img src="https://github.com/JanendraVian/Bellabeat-Case-Study/assets/141770727/943c6ef1-b075-4974-a720-f991a420350e" height="150">|
|:--:| 
| *Image 1* |

The DailyActivity table was given a new column named DayWeek to show the day name of the corresponding date.
```
ALTER TABLE dailyActivity_merged$
ADD DayWeek char(10);

UPDATE dailyActivity_merged$
SET DayWeek = DATENAME(dw, NewActivityDate)
```
The same thing was also done to the SleepDay table.
```
ALTER TABLE sleepDay_merged$
ADD DayWeek char(10);

UPDATE sleepDay_merged$
SET DayWeek = DATENAME(dw, SleepDay)
```
The data from the Sedentary, LightlyActive, FairlyActive, and VeryActive columns were then summed and made into a new table
```
SELECT DISTINCT Id, 
SUM(SedentaryMinutes) as Sedentary,
SUM(LightlyActiveMinutes) as LightlyActive,
SUM(FairlyActiveMinutes) as FairlyActive, 
SUM(VeryActiveMinutes) as VeryActive
INTO NewSUMAct
FROM dailyActivity_merged$
GROUP BY Id
```
Both tables were then joined together into a new table; ```ActivitySleep```. Here, ```INNER JOIN``` was used.
```
SELECT Activity.*, Sleep.TotalSleepRecords, Sleep.TotalMinutesAsleep, Sleep.TotalTimeInBed
INTO ActivitySleep
FROM dailyActivity_merged$ Activity
INNER JOIN sleepDay_merged$ Sleep 
ON Activity.Id = Sleep.Id AND Activity.NewActivityDate = Sleep.NewSleepDay
```
From ```ActivitySleep```, another new table was made (```CompleteData```) that included the addition of 2 new columns; ```TotalActiveMinutes``` and ```TotalActiveDistance```. The two columns would be used for analyzing relationships and other analyses.
```
SELECT *,
(VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes) TotalActiveMinutes,
(VeryActiveDistance+ModeratelyActiveDistance+LightActiveDistance) TotalActiveDistance
INTO CompleteData
FROM ActivitySleep
```
Another new table was made (```TrueDailyActivity```) that included the addition of 2 new columns; ```TrueTotalActiveMinutes``` and ```TrueTotalActiveDistance``` for the same purpose as the table above. This table does not include the joining of the Daily Activity and Sleep table (```ActivitySleep```) because the needed relationship would be less accurate due to joining both tables resulting in less user data.
```
SELECT *,
(VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes) TrueTotalActiveMinutes,
(VeryActiveDistance+ModeratelyActiveDistance+LightActiveDistance) TrueTotalActiveDistance
INTO TrueDailyActivity
FROM dailyActivity_merged$
```

This concludes the processing phase.

## Analysis
The data that had been processed was then put to use in the analysis phase.
### General Findings
From the pie chart based on the ```NewSUMAct``` table below, we can see that users spent 81.33% of their time doing sedentary activities. The percentage included 33 users.

|  <img src="https://github.com/JanendraVian/Bellabeat-Case-Study/assets/141770727/e741ad8a-7227-4d7a-a1e4-458fb025c28a" width="320">  |
|:--:| 
| *Image 2* |

Analysis of the average intensity of activities on each day using the ```CompleteData``` table shows that users did more activities on Saturday (_image 3_). This is reflected when compared to the average sedentary activity which is the lowest on Saturday (_image 4_). However, even though the intensity of activities is the lowest on Sunday, sedentary activities are not the highest on that day. Additionally, users took fewer steps on Sunday and more steps on Saturday (_image 5_), which reflects more activities on that day.
|  <img src="https://github.com/JanendraVian/Bellabeat-Case-Study/assets/141770727/c5e3c514-60a0-48ae-94e6-72bc2ea72d59">  |  <img src="https://github.com/JanendraVian/Bellabeat-Case-Study/assets/141770727/ca02e51c-2fe6-4858-9aa3-546df8064809">  |  <img src="https://github.com/JanendraVian/Bellabeat-Case-Study/assets/141770727/65014e00-882d-445c-b243-3e7667e2710c">  |
|-----|----|----|
| *Image 3* | *Image 4* | *Image 5* |

The analysis of average sleep duration shows that users spent more time asleep on Sunday and had the least sleep duration on Thursday.
|  <img src="https://github.com/JanendraVian/Bellabeat-Case-Study/assets/141770727/73fb558d-3099-47f3-bb47-b9d386608e9e" width="500">  |
|:--:| 
| *Image 6* |

### Activity and Steps
This analysis uses the ```TrueDailyActivity``` table. An interesting finding shows that zero to not much time spent on being active has the same calories burned as investing time in being more active (_image 7_). When further investigated, the representation comes from the LightlyActive, FairlyActive, and VeryActive activity categories while Sedentary activity does not contribute to the findings (_image 8_).
|  <img src="https://github.com/JanendraVian/Bellabeat-Case-Study/assets/141770727/42090682-786e-4818-b30d-c281fe8fed87" width="450">  |
|:--:| 
| *Image 7* |

|  <img src="https://github.com/JanendraVian/Bellabeat-Case-Study/assets/141770727/74a4a77c-7f37-4c9c-b7ba-e3be9245d9b6" width="850">  |
|:--:| 
| *Image 8* |

This also shows that users who spent more time doing more intense activities burned more calories and the more time being less active the fewer calories they burned.

The same interesting findings were also found in the Steps-Calorie relationship. Users who took minimal or fewer steps burned 1000–2500 calories, similar to the amount of calories burned by users who took more steps.
|  <img src="https://github.com/JanendraVian/Bellabeat-Case-Study/assets/141770727/c76765d3-aa82-42fe-bfe3-80ad9ec3786a" width="450">  |
|:--:| 
| *Image 9* |

### Sleep
When looking into the relationships between sleep duration, activity intensities, and calories burned, a few findings were made.
#### Sleep Duration and Sedentary Activity.
There seems to be a sweet spot in the duration of sedentary activity users can take in order to have quality sleep. Sedentary minutes may be counted into sleep duration. However, the more time users spent being sedentary didn't equal longer sleep duration. Meanwhile, users who spent 400–800 minutes being sedentary have better sleep duration based on the recommendation from the National Sleep Foundation which is 7–9 hours.

|  <img src="https://github.com/JanendraVian/Bellabeat-Case-Study/assets/141770727/105aa5ce-d7bc-4b86-a19a-d82ecabf6c2c" width="450">  |
|:--:| 
| *Image 10* |

#### Sleep Duration and Calories Burned
Same with the previous finding, there seems to be a sweet spot between the duration of sleep with calories burned. Three hundred to 600 minutes of sleep duration shows the higher amount of calories burned by users. Additionally, there seems to be a decline in calories burned the longer the duration of sleep.

|  <img src="https://github.com/JanendraVian/Bellabeat-Case-Study/assets/141770727/9f1d5f67-c6c1-4831-9b06-747a11c0dae6" width="450">  |
|:--:| 
| *Image 11* |

## Conclusion and Act
### Conclusion
1. Users are less active on Sunday.
2. Users spent most of their time doing sedentary and light activities.
3. The average daily step count did not meet the 10,000 count, the recommended step count by the CDC.
4. Burning calories is more time-efficient when done in a fairly active to very active intensity.
5. Less activity duration and intensity equals less sleep duration.
### Business-related Recommendation 
1. More data is needed to make a more accurate analysis and better data-driven decisions.
2. Bellabeat can make a feature to inform the user that they spent too much time doing sedentary to light activities.
3. To encourage more intensity and duration of activity, Bellabeat can make a campaign for users to exercise on Sunday.
