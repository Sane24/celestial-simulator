using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using TMPro;

public class DayNight : MonoBehaviour
{
    [SerializeField] private Slider _slider;
    public Material daySkybox;
    public Material blendSkybox;
    public Material nightSkybox;
    public Material nightSkybox2;
    int currentScene = 0;
    [SerializeField] private TMP_Dropdown sceneDropdown;
    // Start is called before the first frame update
    void Start()
    {
        RenderSettings.skybox = nightSkybox;
        _slider.value = 2;
        currentScene = sceneDropdown.value;
    }

    // Update is called once per frame
    void Update()
    {
        currentScene = sceneDropdown.value;
        if(_slider.value == 0){
           RenderSettings.skybox = daySkybox;
        } else if(_slider.value == 1){
           RenderSettings.skybox = blendSkybox;
        } else if(_slider.value == 2 && currentScene == 1){
            RenderSettings.skybox = nightSkybox2;
        }
        else {
            RenderSettings.skybox = nightSkybox;
        }
    }
}
