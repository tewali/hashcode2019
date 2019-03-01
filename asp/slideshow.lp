% Domain definition is in the form of:
% h_image(ImageNumber, ImageTag). and/or
% v_image(ImageNumber, ImageTag). one line for each tag of each image.

% Completing the domain info we need:
slideCount(H+(V/2)) :- #count{ I: h_image(I, _) } = H, #count{ I: v_image(I, _) } = V.

image(I, T) :- h_image(I, T).
image(I, T) :- v_image(I, T).

tag(T) :- h_image(_, T).
tag(T) :- v_image(_, T).

% Generating slides:
{ output(N, I1, 0):
    slideCount(M),
    h_image(I1, _),
		% This somehow doesn't do the trick... but it also doesn't harm - why?
    not output(N, I2, I3), image(I2, _), image(I3, _),
    I1<I2, I1<I3
    } 1 :- slideCount(M), N=1..M.

{ output(N, I1, I2):
    slideCount(M),
    v_image(I1, _),
    v_image(I2, _), I1<I2,
		% This somehow doesn't do the trick... but it also doesn't harm - why?
    not output(N, I3, I4), image(I3, _), image(I4, _),
    I1<I3, I1<I4
    } 1 :- slideCount(M), N=1..M.

% Should not contain outputs twice
:- output(N, I1, _), output(N, I2, _), I1>I2.

% Should contain exactly n output slides
:- { output(_, _, _) } != M, slideCount(M).

% Now optimize!
slide(N, T) :- output(N, I, _), image(I, T).
slide(N, T) :- output(N, _, I), image(I, T).

tmp_min(A, Same, InA, InB) :-
    { slide(A,T): slide(A, T), slide(A+1, T) } = Same,
    { slide(A,T): slide(A, T), not slide(A+1, T) } = InA,
    { slide(A+1,T): not slide(A, T), slide(A+1, T) } = InB,
    slideCount(M),
    A=1..M.

% This is inefficient - can we not use some built in function?
min(N, S) :- tmp_min(N, S, A, B), S<=A, S<=B.
min(N, A) :- tmp_min(N, S, A, B), A<=S, A<=B.
min(N, B) :- tmp_min(N, S, A, B), B<=S, B<=A.

#maximize { M,1: min(N, M) }.

#show output/3.
