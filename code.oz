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



   %Translates a chrod to the extended notation
   fun {ChordToExtended Chord}
      case Chord
      of H|T then
         {NoteToExtended H}|{ChordToExtended T}
      [] Atom then {NoteToExtended Chord}
      else nil
      end
   end



   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



   %Multiplies the duration of a note by a factor
   fun {Stretch Factor Partition}
      case Partition
      of Name#Octave then {Stretch Factor {NoteToExtended Partition}}
	 [] silence(duration:D) then silence(duration:D*Factor)
      [] note(name:A octave:B sharp:C duration:D instrument:E) then
	 note(name:A octave:B sharp:C duration:D*Factor instrument:E)
      [] H|T then case H
		  of note(name:A octave:B sharp:C duration:D instrument:E) then
		     {Stretch Factor H}|{Stretch Factor T}
		  else {Stretch Factor {ChordToExtended Partition}}
		  end
      [] Atom then {Stretch Factor {NoteToExtended Partition}}
      end
   end



   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



   %Calculates the total time of the partition
   fun{Time Partition}
      case Partition
      of note(name:A octave:B sharp:C duration:D instrument:E)
      then Partition.duration
      [] silence(duration:D) then D
      [] H|T then case H
		  of note(name:A octave:B sharp:C duration:D instrument:E)
		  then H.duration+{Time T}
		  else 1.0+{Time T}
		  end
      else 1.0
      end
   end



   fun{Duration Seconds Partition}

      local Di in
	 Di = Seconds/{Time Partition}
	 {Stretch Di Partition}
      end
   end



   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



  % Changes the note to a number
   fun {Num Partition}
      if Partition.name==c then
	 if Partition.sharp==false then 1
	 else 2
	 end
      elseif Partition.name==d then
	 if Partition.sharp==false then 3
	 else 4
	 end
      elseif Partition.name==e then 5
      elseif Partition.name==f then
	 if Partition.sharp==false then 6
	 else 7
	 end
      elseif Partition.name==g then
	 if Partition.sharp==false then 8
	 else 9
	 end
      elseif Partition.name==a then
	 if Partition.sharp==false then 10
	 else 11
	 end
      elseif Partition.name==b then 12
      end
   end



   %Changes the number to a note
   fun {Notee N O D I}
      if N==1 then note(name:c octave:O sharp: false duration:D instrument:I)
      elseif N==2 then note(name:c octave:O sharp: true duration:D instrument:I)
      elseif N==3 then note(name:d octave:O sharp: false duration:D instrument:I)
      elseif N==4 then note(name:d octave:O sharp: true duration:D instrument:I)
      elseif N==5 then note(name:e octave:O sharp: false duration:D instrument:I)
      elseif N==6 then note(name:f octave:O sharp: false duration:D instrument:I)
      elseif N==7 then note(name:f octave:O sharp: true duration:D instrument:I)
      elseif N==8 then note(name:g octave:O sharp: false duration:D instrument:I)
      elseif N==9 then note(name:g octave:O sharp: true duration:D instrument:I)
      elseif N==10 then note(name:a octave:O sharp: false duration:D instrument:I)
      elseif N==11 then note(name:a octave:O sharp: true duration:D instrument:I)
      elseif N==12 then note(name:b octave:O sharp: false duration:D instrument:I)
      end
   end



   % Moves the partition 1 semitone up
   fun{Ajout Partition}
      local N in
	 N={Num Partition}
	 if N==12 then {Notee 1 Partition.octave+1 Partition.duration Partition.instrument}
	 else {Notee N+1 Partition.octave Partition.duration Partition.instrument}
	 end
      end
   end



   % Moves the partition 1 semitone down
   fun{Soustr Partition}
      local N in
	 N={Num Partition}
	 if N==1 then {Notee 12 Partition.octave-1 Partition.duration Partition.instrument}
	 else {Notee N-1 Partition.octave Partition.duration Partition.instrument}
	 end
      end
   end



   %Adds the right amount of semitones and returns de partition
   fun{Tot Semitones Partition}
      if Semitones==0 then Partition
      elseif Semitones>0 then {Tot Semitones-1 {Ajout Partition}}
      else {Tot Semitones+1 {Soustr Partition}}
      end
   end



   %Transposes the Partition a certain number of semitones up or down
   fun{Transpose Semitones Partition}
      case Partition
      of note(name:A octave:B sharp:C duration:D instrument:E)
      then {Tot Semitones Partition}
      [] silence(duration:D) then silence(duration:D)
      [] H|T then case H
	     of note(name:A octave:B sharp:C duration:D instrument:E)
	     then {Tot Semitones H}|{Transpose Semitones T}
	     else
		{Transpose Semitones {ChordToExtended Partition}}
	     end
      else {Transpose Semitones {NoteToExtended Partition}}
      end
   end



   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



   fun {Drone X Amount}
      case Amount of 0 then nil
      else X|{Drone X Amount-1}
      end
   end




   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



   fun {PartitionToTimedList Partition}
      case Partition
      of A#B then {NoteToExtended A#B}
      [] silence(duration:D) then silence(duration:D)
      [] note(name:A octave:B sharp:C duration:D instrument:E)
      then  note(name:A octave:B sharp:C duration:D instrument:E)
      []H|T then {PartitionToTimedList H}|{PartitionToTimedList T}
      [] Atom then
	 case {Label Partition}
	 of 'duration' then {Duration Partition.1 {PartitionToTimedList Partition.2}}
	 [] 'stretch' then {Stretch Partition.1 {PartitionToTimedList Partition.2}}
	 [] 'transpose' then {Transpose Partition.1 {PartitionToTimedList Partition.2}}
	 [] 'drone' then {Drone Partition.1 Partition.2}
	 else {NoteToExtended Atom}
	 end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Returns the number of semitons between Note and A4
   fun{Hauteur Note}
      local Note2 = {PartitionToTimedList Note} in
         case {Label Note2} of 'silence' then 0.0
         [] 'note'
         then 12.0*{IntToFloat Note2.octave} + {IntToFloat {Num Note2}} - 58.0
         else 0.0
         end
      end
   end
   % takes as argument a note and returns a sample of that note
   % marche pas, probleme de type, genre float ou int je sais pas ou
   % peut etre les unites des sinus
   fun{NoteToSample Note}
      H = {Hauteur Note}
      F = {Pow 2 h/12} * 440
      Itot = Note.duration*44100 % nbre d echantillons a faire pour la note
      Pi = 3.14159265359
      local
         fun{DoItAgain C} % peut etre mettre en argument H,F et Itot
            if C == Itot then 1/2*{Sin 2*Pi*F*C/44100}
            else 1/2*{Sin 2*Pi*F*C/44100}|{DoItAgain C+1}
            end
         end
      in {DoItAgain 1}
      end
   end

   end
   % takes as argument a file path and returns a sample
   fun{WavToSample FileName}
      {Project.load FileName} % pas sur que la fonction s'utilise comme ca
   end

   % takes as argument a sample and returns the sample in reversed order
   fun{Reverse Music}
      case Music of H|T then {Reverse T}|H
      else Music
      end
   end

   fun{Repeat Amount Music}
      if Amount == 0 then nil
      else Music|{Repeat Amount-1 Music}
      end
   end

   fun{Loop Seconds Music}

   end

   fun{Clip Low High Music}

   end

   fun{Echo Delay Decay Music}

   end

   fun{Fade Start Out Music}

   end

   fun{Cut Start Finish Music}

   end

   fun{Merge !! arguments ? !!}

   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTRES FONCTIONS
   % takes as argument a sample, and return the number of samples in that sample
   fun{SampInMusic Music}
      local
         fun{SampInMusAcc Mus Acc}
            case Mus
            of H|T then {SampInMusAcc T Acc+1}
            else Acc+1
            end
         end
      in {SampInMusAcc Music 0}
      end
   end

   % takes a sample as an argument, returns the number of seconds in that sample
   fun{SecInMusic Music}
      {SamPinMusic Music}/44100
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % !! si on a une partition il faut faire P2T(Partition)
   % et pas PartitionToTimedList(Partition)
   fun {Mix P2T Music}
      case Music
      of H|T then
         case {Label H}
         of 'partition' then {PartToSamp {P2T H.1}}|{Mix P2T T}
            [] 'samples' then H.1|{Mix P2T T}
            [] 'wave' then {WavToSample H.1}
            [] 'merge' then
            [] 'reverse' then {Reverse {Mix P2T T} }
            [] 'repeat' then
            [] 'loop' then
            [] 'clip' then
            [] 'echo' then
            [] 'fade' then
            [] 'cut' then
      []
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
