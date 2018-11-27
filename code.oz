local
   % See project statement for API details.
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
         case {AtomToString Atom}
         of [_] then
            note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
         [] [N O] then
            note(name:{StringToAtom [N]}
                 octave:{StringToInt [O]}
                 sharp:false
                 duration:1.0
                 instrument: none)
         end
      end
   end
   
   % A VERIFIER
   % transforme Chord en ExtendedChord
   fun {ChordToExtended Chord}
      case Chord
      of H|T then
         {NoteToExtended H}|{ChordToExtended T}
      else nil
      end
   end
   
   
   %on multiplie la duration de chaque note et extendedChord par le facteur
   fun {Stretch Factor Partition}
      case Partition
      of Name#Octave then {Stretch {NoteToExtended Partition}}
      [] note(name:A octave:B sharp:C duration:D instrument:E) then
	 note(name:A octave:B sharp:C duration:D*Factor instrument:E)	 
      [] H|T then case H
		  of Name#Octave then {Stretch {ChordToExtended Partition}}
		  [] note(name:A octave:B sharp:C duration:D instrument:E) then
		     local Q in
			Q = {NewCell nil}
			for U in Partition
			   local T in
			      case U of note(name:A octave:B sharp:C duration:D instrument:E) then
				 T=note(name:A octave:B sharp:C duration:D*Factor instrument:E)
			      end
			      Q:= @Q|T
			   end
			end
		     @Q
		     end
		  [] Atom then {Stretch {ChordToExtended Partition}}
		  end
      [] Atom then {Stretch {NoteToExtended Partition}}
      end
   end
   
   % A VERIFIER
   % faire la distinction si c'est une note ou un accord
   %crée une liste avec la meme note/accord un certain nombre de fois (amount)
   fun {Drone Note Amount}
      local A = {NewCell nil} in
         for X in 1..Amount
            A:= {NoteToExtended Note}|@A
         end
         @A
      end
   end
 
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}
      local FlatList = nil in
         for U in Partition
            case U
            of 
         
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      {Project.readFile 'wave/animaux/cow.wav'}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load 'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
