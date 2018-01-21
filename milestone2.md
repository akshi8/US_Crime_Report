# Week 3 - Project Milestone 2: First submission

### Tidy Submission (15%)

rubric={mechanics:15}

* Develop your shiny app on a **public github.com** repository (don't forget, we'll be considering your commits when grading your final submission in Milestone 3).
* Deploy your Shiny app to shinyapps.io. Sometimes deployment will introduce bugs, so make sure to save some time for debugging! The shinyapps.io console logs are very helpful here.
* Tag a release of your Shiny app, and submit a link to that in your private repository for this milestone. Tagging a release will allow you to continue developing the app, even before Milestone 2 is graded.
* In addition to your Shiny app submission, you must document the functionality of your Shiny app in a markdown document in your **private student repository** for this milestone. **YOU MUST INCLUDE SCREENSHOTS** illustrating all of the functions your Shiny app performs. If your Shiny app fails to deploy to shinyapps.io, we will be grading you solely on your screenshots.
* Ensure that your markdown submission as a whole is easy to read: use appropriate formatting that clearly distinguishes between our questions and your answer, between different sub-parts of your answer, and with visible differences between code and English.
* Ensure your submitted private repo is organized. It should be easy to find files and links.

### Interactive Shiny app, first draft (75%)

rubric={code:45,viz:30}

Work to turn your project proposal into a fully operable Shiny app!

* Build a dashboard interface for the dataset you have chosen to work with.
* Create interactive visualizations that let a user explore the dataset.
* Implement the features you outlined in your proposal, paying close attention to usability.
* Keep your usage scenario (from your proposal) in mind when designing your interface. Make sure that your app's interface and functionality would allow a user to answer your proposed questions.
* Your interface should be as self-documenting as possible, with appropriate labels for panes and widgets, a legend documenting the meaning of visual encodings, and a meaningful title for the app.
* Your goal is not to fully complete the analysis yourself and draw conclusions about the data, it's to build a tool that would allow somebody else to do such an analysis. Your job is to think about how to build such a tool and to provide explicit arguments of why your visualization design choices are a reasonable solution. You might do some analysis along the way to convince yourself and to demonstrate that you've made reasonable choices, but the analysis itself is not the subject of the marking. Also note that you need not make a "masterpiece" -- the goal is the use the time you have available this week to create a compelling app. No need to go overboard.

* Development Note: It can be easy to get sucked into a rabbit hole when trying to implement a stubborn feature. While it is important to build skills troubleshooting, we do not want one feature to prevent you from completing the full first draft of your app. If you're stuggling with a particularly tough problem, save it for the end or ask a TA for help! This week we'll be covering debugging Shiny apps, which may help you solve those tougher bugs.

### Writeup (10%)

rubric={reasoning:8,writing:2}

* Your writeup should include the rationale for your design choices, focusing on the interaction aspects and connecting these choices to a data abstraction (including a characterization of the raw data types and their scale/cardinality, and of any derived data that you decide compute) and the task abstraction (including a more detailed breakdown of tasks that arise from the goal stated above). You should also concisely describe your visual encoding choices.

* Talk about how your vision has changed since your proposal
  * How have your visualization goals changed?
  * Does your app enable the tasks you set out to facilitate?
