using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class speedToggle : MonoBehaviour
{
    // public Material auroraMat;
    public matSelector matSelector;
    Material mat;
    [SerializeField] private Slider _slider;
    [SerializeField] private TextMeshProUGUI _sliderText;
    private float speed;

    void Start()
    {
        mat = matSelector.currMat;
        _slider.value = 0.4f;
        mat.SetFloat("_Speed", 0.4f);
        _slider.onValueChanged.AddListener((v) => {
           _sliderText.text = $"Speed: {v:F1}";
            UpdateSpeed(v);
        });
    }
    void Update()
    {
        Material newmat = matSelector.currMat;
        if(newmat != mat){
            mat = newmat;
            _slider.value = mat.GetFloat("_Speed");
        }
    }

    void UpdateSpeed(float speed)
    {
        
        mat.SetFloat("_Speed", speed);
    }


}
