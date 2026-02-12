using Godot;
using System;
using GodotInk;

public partial class InkyHandler : Node
{
	[Signal]
	public delegate void DialogueStartedEventHandler();
	[Signal]
	public delegate void DialogueEndedEventHandler();
	private InkStory defaultStory;
	private InkStory currentStory;
	private PackedScene dialogueInterface;
	private Control interfaceInstance;
	
	//Initializes InkyHandler and loads default story
	public override void _Ready()
	{
		defaultStory = (InkStory) GD.Load("res://Assets/Dialogue/JoelleDialogueTest.ink");
		currentStory = defaultStory;
		dialogueInterface = GD.Load<PackedScene>("res://Scenes/Dialogue Interface/dialogue_interface.tscn");
		GD.Print("Inky Handler loaded");
		PlayStoryFromStart();
	}
	
	public void SetNewStory(InkStory newStory){
		currentStory = newStory;
	}
	
	//Plays current story from the start
	public void PlayStoryFromStart(){
		PlayDialogue();
	}
	
	//Plays current story starting at specified knot
	//Knot Name: <level>_<progress>_<placement> ex. Level1_2_Start (Before second time playing level 1)
	public void PlayStoryFromKnot(string knotName){
		if(knotName != ""){
			currentStory.ChoosePathString(knotName);
		}
		PlayDialogue();
	}
	
	public InkStory GetCurrentStory()
	{
		return currentStory;
	}
	
	public void EndDialogue(){
		interfaceInstance.QueueFree();
		EmitSignal(SignalName.DialogueEnded);
	}
	
	private void PlayDialogue(){
		interfaceInstance = (Control) dialogueInterface.Instantiate();
		AddChild(interfaceInstance);
		EmitSignal(SignalName.DialogueStarted);
	}
}
