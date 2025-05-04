using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
using TMPro;

public class matSelector : MonoBehaviour
{
    [SerializeField] private TMP_Dropdown matDropdown;
    [SerializeField] private List<Material> targetMaterials = new List<Material>();

    public Material currMat;
    private List<string> displayNames = new List<string> {  "Multi-Motion Aurora", "Procedural Aurora", "Sine Aurora", "Spectral Aurora"};

    void Start()
    {
        matDropdown.ClearOptions();
        matDropdown.AddOptions(displayNames);

        matDropdown.onValueChanged.AddListener(OnDropdownChanged);
    }

    void OnDropdownChanged(int index)
    {
        currMat = targetMaterials[index];
      
    }

}
