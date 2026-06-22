# Feedback on PR Walkthrough

## The Problem

1. Lack of context that are outside the PR. Yes the PR will introduce new concepts, but sometimes a PR is one piece of a larger system, scenario etc. Disconnected from other context can make it hard to understand.
2. High level explanation is not easy to understand.
3. The partition of PR into steps are not very good, I often feel disconnected going from one step to another. The order is also not very impressive.
4. There are questions that I ask very often after each step. It would be great that you as the guide can thoughtfully embed those FAQs already.

## The Proposal

First a paradigm transformation. Instead of organizing this as a conversation between you and me, I would like the procedure to be you and me collaborate to create a html "visual book" that fully explains the PR, and in completing this "exercise", I get to understand the PR completely. During our interaction if we spot something wrong (needs improvement, needs fix, needs refactor, needs partial re-design) etc, similarly as before, we plan it and ask a subagent to do the implementation and update the "visual book".

You will still need to read the PR and relevant code and documents first, including sibling repos if there are (e.g. backend repo and frontend repo). Understand how the PR fits into the big picture, and especially if there is a specific problem that the PR is about, tell the story of this specific problem first. This is the high level understanding we are talking about. Initialize the "visual book" html by only having the first chapter - how the PR solves that problem. Visualize it instead of just write a lot of text. If we can use an example (or more than one examples) to tell the story, that would be even better. Naturally fit the high level components/concepts/classes/functions etc into the story so we can have an absolute good understanding of the skeleton and backbone of the solution provided by the PR. At this stage, the important questions that we might want to ask ourselves is that: are there too many high level concepts/components? Are they absolutely necessary? What are the important assumptions?

`xdg-open` the html once it is created.

Once the high level is good. We can move on to next level of details. The number of levels depends on the complexity of the PR. Each level can be broken down to bite size components/concepts/features etc to go through. This procedure went on until we finished all the lowest level stuff. The order can be depth first or breadth first or even mixed depending on what you think is the best way for me to understand.

At each bite size step, we add a new section in the html to visualize and go over the data model, behavior and code logic. Use visualization techniques a lot to make sure it is easy to read and understand. Similarly, consider simplicity, readability, performance, SRP, DRY principles etc. Among everything, I hate complexity the most, so be sure to put some weight on that.

Whenever the html is updated, I will refresh the `xdg-open`ed html to view the new content. And then I will ask questions or give instructions to move on. The procedure is finished when I gained enough confidence that the design and the implementation is sound, correct, good for the future, and without over abstraction.

## Appendix: The crtieria and review of design principoles

Below I will list my criteria. I know they are not like fully disjoint or independent, because they usually affect each other. Still I want to lay them out so that you can understand.

1. Simplicity: Over abstraction or premature optimization can dramatically increase the complexity, and that is the top enemey of me. As a negative feedback loop, it will damage readability, hurt my (and potentially my collaborator, being AI or human) speed and quality of review, and therefore hurt the design and implementation of the future PRs, which will have to increase the complexity of project itself in turn.
   - Having a new concept has its cost and every new concept needs to earn its place. Unnecessary classes, functions, especially those that are hard to get named right, are indicators of over abstraction. Pre-mature optimization are usually the one that brings in the over abstraction (because of unnecessary concetps).
   - It is ok to have a complicated logic for performance sake as long as the logic is very local and the complexity does not bleed out. Otherwise simplicity wins over performance concerns.
   - We are fighting a long term war when working on big projects, and has a "complexity" budget. And therefore I need to make sure we spend that budget cleverly.
2. Architecture decisions. Usually even before the PR is made, I will discuss with an agent like you and the important architecture decisions are already made. However, there can still be cases that important decisions need to be questioned only after the implementation is out, because the previously seemd-correct decisions can become a problem, e.g. the trade off might not seem good when looking at the code, at the cost of bad performance, bad readability etc.
   - Good architecture also help logic to stay where they are without a lot of Single-Responsibility-Principle violations, which imporves readability (see below).
3. Readability. Why do we care about readability if coding agent is writing all the code? Well this is partly because I am still in the loop and readability help me understand the code faster, and therefore in long term deliver the project faster.
   - SRP definitely helps. Without it to understand part of the code I will have to look at many places in many files in future review.
   - Naming matters. Most of the variable, functions, classes, especially those that are no local and interact with other parts of the code, need to have good naming. The test is simple - how many other code do you need to read to understand what it is. If we know that just by looking at the name, that is perfect. On the other extreme if we have to look at lots of files, call sites etc to figure that out, it is probably bad naming. In lots of cases, the bad naming itself suggest very bad design and abstraction, i.e. the class or funciton probably should not be abstracted out in the first place, and as a result it is hard to find a good name for them.
4. Correctness: The logic need to be correct in a way that it does solve the problems and cover edge cases.
5. Tests: the goal of the tests are to boost my confidence as well. They should be testing important invariances, complicated logic etc. The tests that are trivial, or mostly testing mock up logic instead of the real logic, do not earn their places and need to be gone, period.
6. Performance: this is an important aspect of the code and I care performance very much. That being said, I would happily trade performance for simplicity in most cases, if the performance gain is marginal in real world cases.
