# Template Documentation

## Documentation for `formel` [inline]

Other names: *formel*

A math environment for formulas to distinct them from the surrounding
text.

The content of this template must always be *one and only one* math tag!


### Template Attributes:

  - `1` *(formel)* [**required**][**is_math_tag**]: 

    The formula defined in this environment.



## Documentation for `anker` [inline]

Other names: *anker*

Anchors mark reference points in headings.

The argument this anchor is given should be the same as used for
the reference later.


### Template Attributes:

  - `1` [**required**][**is_plain_text**]: 

    The label of this reference.



## Documentation for `:mathe für nicht-freaks: vorlage:hauptartikel` [inline]

Other names: *:mathe für nicht-freaks: vorlage:hauptartikel*

Link to an article covering this section more deeply.

### Template Attributes:

  - `1` [**required**][**is_plain_text**]: 

    The name of the article which covers more deeply the current content.
    



## Documentation for `todo` [block]

Other names: *todo*

A remark for a task which need to be done in an article.

### Template Attributes:

  - `1` [**required**][**everything_is_allowed**]: 

    The content of the todo remark.



## Documentation for `noprint` [box]

Other names: *noprint*

A section which shall not be printed in a PDF export.

### Template Attributes:

  - `1` [**required**][**everything_is_allowed**]: 

    The content which shall not be printed.



## Documentation for `important` [block]

Other names: *important, -*

Environment for highlighting an important block of text.

### Template Attributes:

  - `1` [**required**][**block_or_inline**]: 

    The important content.



## Documentation for `:mathe für nicht-freaks: vorlage:definition` [box]

Other names: *:mathe für nicht-freaks: vorlage:definition*

A definition which defines a mathematical concept given by `title`.


### Template Attributes:

  - `titel` [**optional**][**is_inline_only**]: 

    Name of the mathematical concept which is defined.

  - `definition` [**required**][**block_or_inline**]: 

    The definition of the mathematical content.



## Documentation for `:mathe für nicht-freaks: vorlage:frage` [box]

Other names: *:mathe für nicht-freaks: vorlage:frage*

A question with an answer. `kind` defines the type of the question and
`indent_mode` specifies whether the answer shall be indented (default mode)
or not.


### Template Attributes:

  - `frage` [**required**][**block_or_inline**]: 

    The question.

  - `antwort` [**required**][**block_or_inline**]: 

    The answer of the question.

  - `hinweis` [**optional**][**block_or_inline**]: 

    A hint for the question.

  - `typ` [**optional**][**is_plain_text**]: 

    The kind of the question.

  - `einrückung` [**optional**][**is_negative_switch**]: 

    Defines whether the answer shall be indented.



## Documentation for `:mathe für nicht-freaks: vorlage:satz` [box]

Other names: *:mathe für nicht-freaks: vorlage:satz*

A mathematical theorem.

### Template Attributes:

  - `titel` [**optional**][**is_plain_text**]: 

    Name of the mathematcial theorem.

  - `satz` [**required**][**block_or_inline**]: 

    The content of the theorem.

  - `erklärung` [**optional**][**block_or_inline**]: 

    An explanation for the mathematical theorem.

  - `beispiel` [**optional**][**block_or_inline**]: 

    An example for an application of the theorem.

  - `lösungsweg` [**optional**][**block_or_inline**]: 

    The thought process how to find the proof of this theorem.

  - `zusammenfassung` [**optional**][**block_or_inline**]: 

    A summary for the proof of this theorem.

  - `beweis` [**optional**][**block_or_inline**]: 

    The proof for this theorem.

  - `beweis2` [**optional**][**block_or_inline**]: 

    An alternative proof for this theorem.



## Documentation for `:mathe für nicht-freaks: vorlage:beispiel` [box]

Other names: *:mathe für nicht-freaks: vorlage:beispiel*

A mathematical example.

### Template Attributes:

  - `titel` [**optional**][**is_plain_text**]: 

    A name for this example.

  - `beispiel` [**required**][**block_or_inline**]: 

    The content for this example.



## Documentation for `:mathe für nicht-freaks: vorlage:aufgabe` [box]

Other names: *:mathe für nicht-freaks: vorlage:aufgabe*

An exercise.

### Template Attributes:

  - `titel` [**optional**][**is_plain_text**]: 

    A name for this excersise.

  - `aufgabe` [**required**][**block_or_inline**]: 

    The content for this exercise.

  - `erklärung` [**optional**][**block_or_inline**]: 

    An additional explanation for this exercise.

  - `zusammenfassung` [**optional**][**block_or_inline**]: 

    A summary for the proof or the solution for this exercise.

  - `lösungsweg` [**optional**][**block_or_inline**]: 

    The thought process for finding the proof or the solution of this
    exercise.
    

  - `lösung` [**optional**][**block_or_inline**]: 

    The solution for this exercise.

  - `beweis` [**optional**][**block_or_inline**]: 

    The proof for this exercise.



## Documentation for `:mathe für nicht-freaks: vorlage:gruppenaufgabe` [box]

Other names: *:mathe für nicht-freaks: vorlage:gruppenaufgabe*

An exercise with a set of subexercises.

If your exercise has subtasks which can be solved individually,
you should use this template. 


### Template Attributes:

  - `titel` [**optional**][**is_plain_text**]: 

    A name for this group of excersise.

  - `aufgabe` [**optional**][**block_or_inline**]: 

    The content for this exercise.

  - `erklärung` [**optional**][**block_or_inline**]: 

    An explanation for the exercise.
    
    This should be general information about the problem which
    applies for all subtasks.
    

  - `teilaufgabe1` [**optional**][**block_or_inline**]: 

    Subtask number 1.

  - `teilaufgabe2` [**optional**][**block_or_inline**]: 

    Subtask number 2.

  - `teilaufgabe3` [**optional**][**block_or_inline**]: 

    Subtask number 3.

  - `teilaufgabe4` [**optional**][**block_or_inline**]: 

    Subtask number 4.

  - `teilaufgabe5` [**optional**][**block_or_inline**]: 

    Subtask number 5.

  - `teilaufgabe6` [**optional**][**block_or_inline**]: 

    Subtask number 6.

  - `teilaufgabe1-lösung` *(teilaufgabe1-solution)* [**optional**][**block_or_inline**]: 

    Solution for subtask number 1.

  - `teilaufgabe2-lösung` *(teilaufgabe2-solution)* [**optional**][**block_or_inline**]: 

    Solution for subtask number 2.

  - `teilaufgabe3-lösung` *(teilaufgabe3-solution)* [**optional**][**block_or_inline**]: 

    Solution for subtask number 3.

  - `teilaufgabe4-lösung` *(teilaufgabe4-solution)* [**optional**][**block_or_inline**]: 

    Solution for subtask number 4.

  - `teilaufgabe5-lösung` *(teilaufgabe5-solution)* [**optional**][**block_or_inline**]: 

    Solution for subtask number 5.

  - `teilaufgabe6-lösung` *(teilaufgabe6-solution)* [**optional**][**block_or_inline**]: 

    Solution for subtask number 6.



## Documentation for `:mathe für nicht-freaks: vorlage:hinweis` [box]

Other names: *:mathe für nicht-freaks: vorlage:hinweis, hinweis*

A hint for the reader.

### Template Attributes:

  - `1` [**required**][**block_or_inline**]: 

    The content of this hint.



## Documentation for `:mathe für nicht-freaks: vorlage:warnung` [box]

Other names: *:mathe für nicht-freaks: vorlage:warnung, warnung*

A warning for the reader.

### Template Attributes:

  - `1` [**required**][**block_or_inline**]: 

    The content of this warning.



## Documentation for `:mathe für nicht-freaks: vorlage:beweis` [box]

Other names: *:mathe für nicht-freaks: vorlage:beweis*

A proof for a theorem.

### Template Attributes:

  - `titel` [**optional**][**is_plain_text**]: 

    The name of the theorem which will be proved.

  - `beweis` [**required**][**block_or_inline**]: 

    The content of the proof.



## Documentation for `:mathe für nicht-freaks: vorlage:lösungsweg` [box]

Other names: *:mathe für nicht-freaks: vorlage:lösungsweg*

It shows the way how a solution or a proof for an exercise can be found.


### Template Attributes:

  - `titel` [**optional**][**is_plain_text**]: 

    The title of the theorem or exercise which is going to be proved.
    

  - `lösungsweg` [**required**][**block_or_inline**]: 

    The thought process for finding the solution.



## Documentation for `:mathe für nicht-freaks: vorlage:alternativer beweis` [box]

Other names: *:mathe für nicht-freaks: vorlage:alternativer beweis*

An alternative proof for a theorem.

### Template Attributes:

  - `titel` [**optional**][**is_plain_text**]: 

    The name of the proof which is going to be proved.

  - `beweis` [**required**][**block_or_inline**]: 

    The content of the proof.



## Documentation for `:mathe für nicht-freaks: vorlage:beweiszusammenfassung` [box]

Other names: *:mathe für nicht-freaks: vorlage:beweiszusammenfassung*

A summary of a proof which explains how it works.

### Template Attributes:

  - `titel` [**optional**][**is_plain_text**]: 

    The name of the theorem which is proved.

  - `zusammenfassung` [**required**][**block_or_inline**]: 

    The content of the proof summary.



## Documentation for `:mathe für nicht-freaks: vorlage:lösung` [box]

Other names: *:mathe für nicht-freaks: vorlage:lösung*

A solution (for example for an exercise).

### Template Attributes:

  - `titel` [**optional**][**is_plain_text**]: 

    The title of the exercise this solution has.

  - `lösung` [**required**][**block_or_inline**]: 

    The content of the solution.



## Documentation for `:mathe für nicht-freaks: vorlage:beweisschritt` [block]

Other names: *:mathe für nicht-freaks: vorlage:beweisschritt*

One step of a proof.

### Template Attributes:

  - `name` [**optional**][**is_plain_text**]: 

    The name of the proof step.

  - `ziel` [**required**][**is_inline_only**]: 

    The goal for this proof step.

  - `beweisschritt` [**required**][**block_or_inline**]: 

    The proof for the specified goal.



## Documentation for `:mathe für nicht-freaks: vorlage:vollständige induktion` [block]

Other names: *:mathe für nicht-freaks: vorlage:vollständige induktion, :aufgabensammlung: vorlage:vollständige induktion*

A proof by induction.

### Template Attributes:

  - `erfuellungsmenge` [**optional**][**is_inline_only**]: 

    The set of all objects for which a statement shall be proved by
    induction.
    

  - `aussageform` [**required**][**block_or_inline**]: 

    The statement which shall be proved by induction.

  - `induktionsanfang` [**required**][**block_or_inline**]: 

    The proof of the base case for the induction.

  - `induktionsvoraussetzung` [**required**][**block_or_inline**]: 

    The hypothesis of the step case.

  - `induktionsbehauptung` [**required**][**block_or_inline**]: 

    The goal of the step case.

  - `beweis_induktionsschritt` [**required**][**block_or_inline**]: 

    The proof of the step case.



## Documentation for `:mathe für nicht-freaks: vorlage:fallunterscheidung` [block]

Other names: *:mathe für nicht-freaks: vorlage:fallunterscheidung*

A proof by cases.

### Template Attributes:

  - `fall1` [**required**][**is_inline_only**]: 

    The goal of the 1st case.

  - `beweis1` [**required**][**block_or_inline**]: 

    The proof of the 1st case.

  - `fall2` [**required**][**is_inline_only**]: 

    The proof of the 2nd case.

  - `beweis2` [**required**][**block_or_inline**]: 

    The proof of the 2nd case.

  - `fall3` [**optional**][**is_inline_only**]: 

    The proof of the 3rd case.

  - `beweis3` [**optional**][**block_or_inline**]: 

    The proof of the 3rd case.

  - `fall4` [**optional**][**is_inline_only**]: 

    The proof of the 4th case.

  - `beweis4` [**optional**][**block_or_inline**]: 

    The proof of the 4th case.

  - `fall5` [**optional**][**is_inline_only**]: 

    The proof of the 5th case.

  - `beweis5` [**optional**][**block_or_inline**]: 

    The proof of the 5th case.

  - `fall6` [**optional**][**is_inline_only**]: 

    The proof of the 6th case.

  - `beweis6` [**optional**][**block_or_inline**]: 

    The proof of the 6th case.



## Documentation for `#invoke:mathe für nicht-freaks/seite` [block]

Other names: *#invoke:mathe für nicht-freaks/seite*

Template for including a navigation element (a header or a footer) in an article.


### Template Attributes:

  - `1` [**required**][**is_navigation_spec**]: 

    The kind of the navigational element. "oben" for the header and "unten"
    for the footer.
    

  - `überprüft` [**optional**][**block_or_inline**]: 

    List of reviewers. (only in footer)
    



## Documentation for `smiley` [inline]

Other names: *smiley*

Insert a smiley. Please only use the text description for consistency.


### Template Attributes:

  - `1` [**optional**][**is_plain_text**]: 

    The smiley name like "smile", "wink", "cool", ...
    

  - `2` [**optional**][**is_plain_text**]: 

    The smiley size in pixels.
    



## Documentation for `literatur` [inline]

Other names: *literatur, literature*

Refers to some information from a work of literature.

### Template Attributes:

  - `autor` *(author)* [**optional**][**is_plain_text**]: 

    Full author's names. (Name, Surname, Name, Surname, ...)

  - `titel` *(title)* [**required**][**is_plain_text**]: 

    Full title.

  - `verlag` *(publisher)* [**optional**][**is_plain_text**]: 

    Name of the publishing company.

  - `jahr` *(year)* [**optional**][**is_plain_text**]: 

    Year of publication.

  - `ort` *(address)* [**optional**][**is_plain_text**]: 

    Place or adress of publisher.

  - `isbn` [**optional**][**is_plain_text**]: 

    ISBN of the work if applicable.

  - `seiten` *(pages)* [**optional**][**is_plain_text**]: 

    Pages cited.



