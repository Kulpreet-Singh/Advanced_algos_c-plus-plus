:- dynamic known_answers/3.
:- dynamic patient_record/2.
:- dynamic illness/2.
%------------------
% symptom
% if you want to add more symptoms, just add more predicates below
%------------------
symptom(fever).
symptom(cough).
symptom(shivering).
symptom(runny_nose).
%------------------
% new_patient/1
% starts a new session
% It must be initiated with a patent name.
% This goal clears all known_answers,
% and starts the examine subgoal followed by diagnosis subgoal.
%------------------
new_patient(PatientName) :- not(patient_already_exists(PatientName)),
retractall(known_answer(_,_,_)),write('\nStarting examination...\n'),examine,confirmed_symptoms(S), write('\nConfirmed symptoms are '),
write_term(S, []), write('\n'), assert(patient_record(PatientName,S)), !,
write('Determining illness...\n'), diagnose(S,I),!, write('AI diagnosed that you have '),
write_term(I, []), !.
%------------------
% symptoms/1
% returns a list of all symptoms
%------------------
symptoms(L) :-findall(X, symptom(X), L).
%------------------
% examine/0
% starts the examination process
% by asking for a yes/ no question against each symptom
%------------------
examine :- symptoms(L), check_symptoms(L).
% ------------------
% diagnose/2
% starts the diagnosis process by checking PatientSymptoms and unifying the Illness
% This works by checking whether an Ilness exists with symptoms being
% subset of PatientSymptoms ------------------
diagnose(PS, I) :- length(PS, MustMatchCount), diagnose(PS, MustMatchCount, I).
%------------------
% diagnose/2
% The following predicate is expected to match when no other illness is identified.
%------------------
diagnose(_, unknown_disease).
%------------------
% diagnose/3
% recursively matches the illness symptoms and patient symptoms with
% decreasing number of matches PS: Patient Symptoms (expected to be
% passed as a parameter) I: Illness (expected to be unified)
% MustMatchCount: The number of symptoms that should exist in Illness
% ------------------
diagnose(PS, MustMatchCount, I) :- ( illness(I,S), length(S, MustMatchCount),
subset(S,PS),! ); (MustMatchCount > 1, NewCount is MustMatchCount-1,
diagnose(PS, NewCount, I) ).
%------------------
% check_symptoms/1
% given a list of symptoms, ask quetions
%------------------
check_symptoms([]) :- !.
check_symptoms([H|T]) :- ask(symptom,H), check_symptoms(T).
%------------------
% confirmed_symptoms/1
% returns a list of symptoms for which the answer is yes
%------------------
confirmed_symptoms(C) :- findall(X,known_answer(yes,symptom,X),C).
%------------------
% ask/2
% given an attribute and a value, gets a yes/no answer from the user
% It works by writing a prompt and having a subgoal to assert the answer
%------------------
ask(Attr,Val) :-write(Attr:Val), write('? '), read(Y), asserta(known_answer(Y,Attr,Val)).
%------------------
% fix_diagnosis/2
% learns "actual" illness of a "patient" and improves the learning process
%------------------
fix_diagnosis(PatientName, ActualIllness) :- patient_record(PatientName, PS),
write('Confirmed patient symptoms '), write_term(PS, []),
write(' will be related to '), write_term(ActualIllness, []), !, update_definition(ActualIllness, PS, FS),!, write('\nNew definition is '), write_term(FS,[]).
%------------------
% update_definition/3
% given an illness and new symptoms, returns the updated symptoms for that illness
% Following case is when the illness is not already defined.
%------------------
update_definition(Illness, RelateSymptoms, RelateSymptoms) :- not(illness(Illness, _)),
write('\nThere was no earlier definition of '), write_term(Illness, []),assert(illness(Illness, RelateSymptoms)),!.
%------------------
% update_definition/3
% given an illness and new symptoms, returns the updated symptoms for that illness
% Following case is when the illness is already defined, and hence takes
% an intsection of old and new symtpoms ------------------
update_definition(Illness, RelateSymptoms, FinalSymptoms) :- illness(Illness, OldSymptoms),
write('\nEarlier definition of '),write(Illness),write(' was '),
illness(Illness, OldSymptoms),write_term(OldSymptoms,[]),
intersection(OldSymptoms, RelateSymptoms, FinalSymptoms), retractall(illness(Illness,_)),
assert(illness(Illness, FinalSymptoms)).
%----------------------
% rediagnose/1
% given a patient name, rechecks diagnosis based on existing symptoms
% This goal could be requested, for example, when illness predicates are updated
%----------------------
rediagnose(PatientName) :-patient_record(PatientName, C),write('\nConfirmed symptoms were
'),
write_term(C, []),write('\nRediagnosing...'), diagnose(C, NewIllness),!,
write('\nUpdated diagnosis is that Patient '), write_term(PatientName, []),
write(' is having '),write_term(NewIllness, []).
%----------------------
% patient_already_exists/1
% true if given patient name is already in the patient records
%----------------------
patient_already_exists(PatientName) :-patient_record(PatientName,_),
write('Patient '),write_term(PatientName,[]),write(' already exists.\n').
%----------------------
% show_patient_records/0
% shows all patient records
%----------------------
show_patient_records :- findall((P,S), patient_record(P,S), L), !,show_records(L).
%----------------------
% show_records/1
% Calls show_record for each (PatientName, Symptom) pair
%----------------------
show_records([]).
show_records([(P,S)|T]) :- show_record(P,S),show_records(T).
show_record(P, S) :- diagnose(S, I),!, write_term(P, []),write(' has symptoms '),
write_term(S, []), write(' and diagnosed '),
write_term(I, []), write('\n').
%---------------------------
% change_diagnosis/2
% Associate the symptoms from one illness to another for a given patient
%---------------------------
change_diagnosis(Patient, NewIllness) :-patient_record(Patient, Symptoms),!,
write_term(Patient, []),write(' has symptoms '),
write_term(Symptoms, []),diagnose(Symptoms, OldIllness),
write(' and was diagnosed '), write_term(OldIllness, []),
write('\n'),!,write('Changing it to '),
write_term(NewIllness, []),write('\n'),
retractall(illness(NewIllness, _)), retractall(illness(OldIllness, _)),
assert(illness(NewIllness, Symptoms)).
