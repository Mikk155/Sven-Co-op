# aiscripted_sequence

Same as [scripted_sequence](scripted_sequence_english.md), except that this always overrides the AI and never allows any interruptions. See [scripted_sequence](scripted_sequence_english.md).

| Key | Description |
|-----|-------------|
m_iFinishSchedule | Allows you to have the monster's AI schedule change to 'Ambush' when the sequence is done, which means that the monster will be in an attentive state and encounter enemies more actively.
m_iszEntity | Name of the monster which shall do the sequence. When referencing multiple monsters, only one will react. If you want to make use of the search radius, you can also set a monster classname here.
m_iszPlay | Name of the animation to play when the monster arrives at the scripted_sequence's location. Animation names and animations vary between monsters. A model viewer like Jed's Half-Life Model Viewer allows you to look at the animations of a Half-Life model file. The action animation is optional.
m_flRadius | Radius, in units, in which to search for a valid target monster. This will only work if you specified a monster classname for 'Target monster'.
m_flRepeat | Delay, in milliseconds, between checks for whether a valid target monster is within search radius or not. Set this to a large value if not used, as the game even does the check when the 'Search radius' is zero. Setting zero here means that it will check every server frame.
m_fMoveTo | Here, you can set in which manner the monster will move to the scripted_sequence, or to not have it move there at all. 'Turn to face', as all other options besides 'No', means that the monster will end the sequence with looking in the same direction as the scripted_sequence, followed by the action animation. (You may change the scripted_sequence's yaw) 'Instantaneous' means, that the monster will be teleported to the scripted_sequence's position instantly.
moveto_radius | When the monster hits the supplied radius around the script, it'll stop moving and start its sequence. Useful when the area around the scripted_sequence is hard to navigate or you want your monster to stop in a distance from the scripted_sequence no matter from which direction the monster comes.

| Flag | Bit | Description |
|------|-----|-------------|
Repeatable | 4 | The scripted_sequence won't be removed after finishing, allowing to use it again.
Leave Corpse | 8 | If the action animation is a death animation, causing the monster to die, the corpse will not fade out.

- Issues
	- If 'Move to position' is set to 'Instantaneous' and you have an action animation set, the monster may freeze up and no longer react.

- Comportamiento de [activación](triggering_system_english.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | !activator | target |
|------------|---------|--------|---------|------------|--------|
| Plays animation | Plays animation | Plays animation | Plays animation | | sends USE_TOGGLE |