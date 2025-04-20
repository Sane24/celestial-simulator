using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class speedToggle : MonoBehaviour
{
    public Material auroraMat;
    [SerializeField] private Slider _slider;
    [SerializeField] private TextMeshProUGUI _sliderText;
    private float speed;

    void Start()
    {
        _slider.value = 0.5f;
        auroraMat.SetFloat("_Speed", 0.5f);
        _slider.onValueChanged.AddListener((v) => {
           _sliderText.text = $"Speed: {v:F1}";
            UpdateSpeed(v);
        });
    }

    void UpdateSpeed(float speed)
    {
        auroraMat.SetFloat("_Speed", speed);
    }


}
