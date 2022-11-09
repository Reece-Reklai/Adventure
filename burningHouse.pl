/* Burning House -- a sample adventure game, by Reece Reklai.
   Consult this file and issue the command:   start.  */

:- dynamic at/2, i_am_at/1, alive/1.   /* Needed by SWI-Prolog. */
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

/* This defines my current location. */

i_am_at(secondFloorLivingRoom).


/* These facts describe how the rooms are connected. */

path(secondFloorLivingRoom, s, secondFloorWindow).
path(secondFloorWindow, r, secondFloorLivingRoom).
path(secondFloorLivingRoom, w, secondFloorBathroom).
path(secondFloorBathroom, r, secondFloorLivingRoom).
path(secondFloorLivingRoom, e, secondFloorGuestRoom).
path(secondFloorGuestRoom, j, masterBedRoom).
path(secondFloorGuestRoom, r, secondFloorLivingRoom).
path(secondFloorLivingRoom, n, livingRoom).
path(livingRoom, n, frontDoor).
path(frontDoor, r, livingRoom).
path(frontDoor, n, outside) :- at(key, in_hand).
path(frontDoor, n, outside) :- write('Door is locked. Look for a key. '), !, fail.
path(livingRoom, e, bathRoom).
path(bathRoom, r, livingRoom).
path(livingRoom, w, masterBedRoom).
path(masterBedRoom, r, livingRoom).
path(livingRoom, s, window).
path(window, r, livingRoom).

/* These facts tell where the various objects in the game
   are located. */

at(bottle, secondFloorBathroom).
at(key, masterBedRoom).
at(water, bathRoom).
at(40, health).


/* These rules describe how to pick up an object. */

take(X) :-
        at(X, in_hand),
        write('You are already holding it!'),
        nl, !.


take(X) :-
        i_am_at(bathRoom),
        retract(at(X, bathRoom)),
        at(Y, health),
        retract(at(Y, health)),
        assert(at(35, health)),
        write('You found water! You\'re health went up to 35 percent.'),
        nl, !.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        (  at(Y, in_hand) ->
            retract(at(Y, in_hand)),
            assert(at(X, in_hand))  
        ;
            assert(at(X, in_hand))  
        ),
        write('OK.'),
        nl, !.

take(_) :-
        write('I do not see it here.'),
        nl.


/* These rules define the six direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).

r :- go(r).

j :- go(j).                                     

/* This rule tells whats in your inventory. */

i :- 
        nl,
        (  at(X, in_hand) ->
             write(X)
        ;
             writeln('Nothing in hand.')
        ),
        nl.
   
/* This rule tells your current health */

health :-
        nl,
        at(X, health),
        write(X),
        nl.

/* This rule tells how to move in a given direction. */

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        at(X, health),
        retract(at(X, health)),
        Y is X - 5,
        assert(at(Y, health)),

        (   Y is 0 ->
                write('You were burned by the fire.'),
                nl, die
        ;
                write('Your health is now '), write(Y), nl,
                assert(i_am_at(There)),
                look, !
        ).

go(_) :-
        write('You cannot go that way.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).



/* This rule tells how to die. */

die :-
        !, finish.


/* Under UNIX, the   halt.  command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final  halt.  */

finish :-
        nl,
        write('The game is over. Please enter the   halt.   command.'),
        nl, !.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.                   -- to start the game.'), nl,
        write('North = n.  South = s.  East = e.  West = w.  Return = r.  Jump = j.   -- to go in that direction.'), nl,
        write('take(Object).            -- to pick up an object.'), nl,
        write('look.                    -- to look around you again.'), nl,
        write('instructions.            -- to see this message again.'), nl,
        write('health.                  -- to check your health.'), nl,
        write('i.                       -- to check your inventory.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        look.

/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(frontDoor) :-
    at(key, in_hand),
    write('Outside is North of you. You have the key to open the front door.'), nl.

describe(frontDoor) :-
    write('Outside is North of you. The front door is locked, find a key to escape.'), nl,
    write('You can Return to living room.'), nl.


describe(secondFloorLivingRoom) :-
        write('Your house is on fire.'), nl,
        write('You are at the second floor of the building.'), nl,
        write('Your mission is to escape with your life.'), nl,
        write('You are caught on fire, you may want to use water to put some out'), nl,
        write('or you will burn out.'), nl,
        write('On the other hand, you can still escape with fire on you it will leave you with scars'), nl,
        write('There is stairs that is in North of you.'), nl,
        write('There is a window that is South of you.'), nl,
        write('There is a guest room to your East.'), nl,
        write('There is a bathroom to your West.'), nl.

describe(secondFloorGuestRoom) :-
        write('The floor collapsed due to the fire.'), nl,
        write('There is now a hole, do you want to Jump into it.'), nl,
        write('You can Return to second floor living room.'), nl.

describe(secondFloorWindow) :-
        write('The fire is between you and the window. You cannot go any further.'), nl,
        write('You can Return to second floor living room.'), nl.

describe(secondFloorBathroom) :-
        write('The bathroom window is too small to climb into'), nl,
        write('You can Return to second floor living room.'), nl.

describe(livingRoom) :-
        write('You made it to the first floor.'), nl,
        write('The stairs that you came down from are engulfed in flame.'), nl,
        write('There is a master bedroom to your West .'), nl,
        write('There is a bathroom to your East.'), nl,
        write('There is a window South of you.'), nl,
        write('The front door is North of you.'), nl.

describe(masterBedRoom) :-
        write('The guest room floor that was on the second floor fell here.'), nl,
        write('You can Return to first floor living room'), nl.

describe(window) :-
        write('You tried opening the window. It will not budge. You tried to break it but the fire came in front of you.'), nl,
        write('You can Return to first floor living room.'), nl.

describe(bathRoom) :-
        write('There is no window here. Return to first floor living room.'), nl.

describe(outside) :-
        write('You have escaped!! Congrats!'), nl,
        finish, !.
