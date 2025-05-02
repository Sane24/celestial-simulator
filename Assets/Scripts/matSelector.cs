using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
using TMPro;

public class matSelector : MonoBehaviour
{
    [SerializeField] private TMP_Dropdown matDropdown;
    public Material auroraMat;
    public Material MultiMat;
    public Material vertMat;

    public Material currMat;
    // private string[] sceneNames = { "Scenes/mainscene", "Scenes/mountain_scene"};
    private List<string> displayNames = new List<string> { "Multi Color Aurora", "Single Color Aurora", "Vertical Aurora"};

    void Start()
    {
        matDropdown.ClearOptions();
        matDropdown.AddOptions(displayNames);

        matDropdown.onValueChanged.AddListener(OnDropdownChanged);
    }

    void OnDropdownChanged(int index)
    {
        if(displayNames[index] == "Single Color Aurora"){
            currMat = auroraMat;
        } else if(displayNames[index] == "Multi Color Aurora"){
            currMat = MultiMat;
        } else{
            currMat = vertMat;
        }
    }

}
