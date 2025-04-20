using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
using TMPro;

public class SceneChange : MonoBehaviour
{
    [SerializeField] private TMP_Dropdown sceneDropdown;
    private string[] sceneNames = { "Scenes/mainscene", "mountain_scene"};
    private List<string> displayNames = new List<string> { "Water", "Mountains" };

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
    }

}
