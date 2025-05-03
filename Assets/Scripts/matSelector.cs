using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
using TMPro;

public class matSelector : MonoBehaviour
{
    [SerializeField] private TMP_Dropdown matDropdown;
    [SerializeField] private List<Material> targetMaterials = new List<Material>();
    // public Material auroraMat;
    // public Material MultiMat;
    // public Material vertMat;

    public Material currMat;
    // private string[] sceneNames = { "Scenes/mainscene", "Scenes/mountain_scene"};
    private List<string> displayNames = new List<string> { "Multi Color Aurora", "Single Color Aurora", "Aura Aurora", "Multi Motion Aurora", "Spectral Aurora"};

    void Start()
    {
        matDropdown.ClearOptions();
        matDropdown.AddOptions(displayNames);

        matDropdown.onValueChanged.AddListener(OnDropdownChanged);
    }

    void OnDropdownChanged(int index)
    {
        currMat = targetMaterials[index];
        // if(displayNames[index] == "Single Color Aurora"){
        //     currMat = auroraMat;
        // } else if(displayNames[index] == "Multi Color Aurora"){
        //     currMat = MultiMat;
        // } else{
        //     currMat = vertMat;
        // }
    }

}
