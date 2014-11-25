// SIMPLE MAPS.

module org.crsx.hacs.samples.Maps {

// Simple map membership query.
main sort Query | ⟦ ⟨WORD⟩ in ⟨Map⟩ ⟧ ;

// A map is a list of :-separated pairs.
sort Map | ⟦ ⟨WORD⟩ : ⟨WORD⟩, ⟨Map⟩ ⟧ | ⟦ ⟨WORD⟩ : ⟨WORD⟩ ⟧ ;

// The keys and values are words and numbers.
token WORD | [A-Za-z0-9]+ ;

// Helper 'list' data structure sort to collect maps.
sort Mappings | MoreMappings(WORD, WORD, Mappings) | NoMappings ;

// Synthesize helper list that collects all the mappings in a Map.
attribute ↑map(Mappings) ;
sort Map | ↑map ;
⟦ ⟨WORD#key⟩ : ⟨WORD#value⟩, ⟨Map#m ↑map(#map)⟩ ⟧ ↑map(MoreMappings(#key, #value, #map)) ;
⟦ ⟨WORD#key⟩ : ⟨WORD#value⟩ ⟧ ↑map(MoreMappings(#key, #value, NoMappings)) ;

// Synthesize helper list that collects all the reverse mappings in a list.
attribute ↑pam(Mappings) ;
sort Map | ↑pam ;
⟦ ⟨WORD#key⟩ : ⟨WORD#value⟩, ⟨Map#m ↑pam(#pam)⟩ ⟧ ↑pam(MoreMappings(#value, #key, #pam)) ;
⟦ ⟨WORD#key⟩ : ⟨WORD#value⟩ ⟧ ↑pam(MoreMappings(#value, #key, NoMappings)) ;

// We'll provide the answer in clear text.
sort Answer
| ⟦Yes, the map takes ⟨WORD⟩ to ⟨WORD⟩.⟧
| ⟦No, but map gets ⟨WORD⟩ from ⟨WORD⟩.⟧
| ⟦No, the map does not contain ⟨WORD⟩.⟧
;

// Helper scheme to check if a map is in one of the maps.
sort Answer | scheme CheckMapping(WORD, Mappings, Mappings) ;

// If the map and the first member of the list are the same, then we succeed!
CheckMapping(#key, MoreMappings(#key, #value, #map), #pam) → ⟦Yes, the map takes ⟨WORD#key⟩ to ⟨WORD#value⟩.⟧ ;

// If the map was not the same, fall back to a default recursive case.
default CheckMapping(#key, MoreMappings(#_key, #value, #map), #pam) → CheckMapping(#key, #map, #pam) ;

// If the map and the first member of the list are the same, then we succeed!
CheckMapping(#key, NoMappings, MoreMappings(#key, #value, #pam)) → ⟦No, but map gets ⟨WORD#key⟩ from ⟨WORD#value⟩.⟧ ;

// If the map was not the same, fall back to a default recursive case.
default CheckMapping(#key, NoMappings, MoreMappings(#_key, #value, #pam)) → CheckMapping(#key, NoMappings, #pam) ;

// Once there is nothing left to search, we give up.
CheckMapping(#key, NoMappings, NoMappings) → ⟦No, the map does not contain ⟨WORD#key⟩.⟧ ;

// Main program takes a Query and gives an Answer.
sort Answer | scheme Check(Query) ;

// The main program forces the synthesized list before it can check membership.
Check( ⟦ ⟨WORD#key⟩ in ⟨Map#m ↑map(#map) ↑pam(#pam)⟩ ⟧ ) → CheckMapping(#key, #map, #pam) ;

}
