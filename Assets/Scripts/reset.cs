using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class reset : MonoBehaviour
{
    [SerializeField] private Button _button;
    public Material multiMat;
    public Material auroraMat;
    public Material auraMat;
    public matSelector matSelector;
    Material curMat;
    [SerializeField] private Slider _hueSlider;
    [SerializeField] private Slider _speedSlider;
    // Start is called before the first frame update
    void Start()
    {
        curMat = matSelector.currMat;
        _button.onClick.AddListener(() => {
           setSetting();
        });
        setSetting();
    }

    void setSetting(){
        multiMat.SetColor("_Color1", new Color(0.2f, 1f, 0.5f, 1f));
        multiMat.SetColor("_Color2", new Color(0.0f, 0.6f, 1f, 1f));
        multiMat.SetColor("_Color3", new Color(0.8f, 0.3f, 1f, 1f));
        multiMat.SetFloat("_Speed", 0.4f);

        auroraMat.SetColor("_MainColor", new Color(0.2f, 1f, 0.5f, 1f));
        auroraMat.SetColor("_SecondaryColor", new Color(0.0f, 0.6f, 1f, 1f));
        auroraMat.SetFloat("_Speed", 0.5f);

        auraMat.SetColor("_MainColor", new Color(0.2f, 1f, 0.5f, 1f));
        auraMat.SetColor("_SecondaryColor", new Color(0.0f, 0.6f, 1f, 1f));
        auraMat.SetFloat("_Speed", 0.5f);

        _hueSlider.value = 0.0f;
        _speedSlider.value = curMat.GetFloat("_Speed");
    }

}
