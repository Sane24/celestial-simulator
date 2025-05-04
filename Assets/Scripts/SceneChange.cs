using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
using TMPro;

public class SceneChange : MonoBehaviour
{
    [SerializeField] private TMP_Dropdown sceneDropdown;
    public Material nightSkybox;
    public Material nightSkybox2;
    [SerializeField] private Slider _dayNightslider;
    [SerializeField] private Toggle _auroratoggle;
    private string[] sceneNames = { "Scenes/mainscene", "Scenes/mountain_scene"};
    private List<string> displayNames = new List<string> {"Calm Mountain Lake", "Snowy Mountains" };

    void Start()
    {
        sceneDropdown.ClearOptions();
        sceneDropdown.AddOptions(displayNames);

        sceneDropdown.onValueChanged.AddListener(OnDropdownChanged);
        SceneManager.LoadScene(sceneNames[0]);
    }

    void OnDropdownChanged(int index)
    {
        string sceneToLoad = sceneNames[index];
        SceneManager.LoadScene(sceneToLoad);
        _auroratoggle.isOn = true;

        if(_dayNightslider.value == 2 && index == 0){
             RenderSettings.skybox = nightSkybox;
        } else if(_dayNightslider.value == 2 && index == 1) {
            RenderSettings.skybox = nightSkybox2;
        }
    }

}
