using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class colorToggle : MonoBehaviour
{
    //public Material auroraMat;
    public matSelector matSelector;
    Material auroraMat;
    [SerializeField] private Slider _slider;
    [SerializeField] private TextMeshProUGUI _sliderText;

    //multi mat
    private Color baseColor;
    private Color secondColor;
    private Color thirdColor;

    //aurora mat
    private Color mainColor;
    private Color secondaryColor;
    private Dictionary<Material, float> hueMap = new Dictionary<Material, float>();

    private MaterialColors currentMatColors;
    [System.Serializable]
    public struct MaterialColors {
        public Color color1;
        public Color color2;
        public Color color3; 
    }
    private Dictionary<Material, MaterialColors> originalColors = new Dictionary<Material, MaterialColors>();

    void Start()
    {
        auroraMat = matSelector.currMat;
       
      
        baseColor = new Color(0.2f, 1f, 0.5f, 1f);
        secondColor = new Color(0.0f, 0.6f, 1f, 1f);
        thirdColor = new Color(0.8f, 0.3f, 1f, 1f);
        if (auroraMat.HasProperty("_Color3")){
            auroraMat.SetColor("_Color1", baseColor);
            auroraMat.SetColor("_Color2", secondColor);
            auroraMat.SetColor("_Color3", thirdColor);
        }
        else if(matSelector.currMat.HasProperty("_MainColor")){
            mainColor = auroraMat.GetColor("_MainColor");
            secondaryColor = auroraMat.GetColor("_SecondaryColor");
        }
        UpdateMaterialColors();
        currentMatColors = originalColors[auroraMat];


        _slider.onValueChanged.AddListener((v) => {
            _sliderText.text = $"Hue: {v:F2}";
            hueMap[auroraMat] = v;
            UpdateColor(v);
        });
    }

    void Update()
    {
        Material newmat = matSelector.currMat;
        resetSlider();
        if(newmat != auroraMat){
            auroraMat = newmat;
            if (!originalColors.ContainsKey(auroraMat))
            {
                UpdateMaterialColors();
            }

            // currentMatColors = originalColors[auroraMat];
             _slider.onValueChanged.RemoveAllListeners();
          

            if (hueMap.TryGetValue(auroraMat, out float savedHue)){
                _slider.value = savedHue;
            }
            else {
                _slider.value = 0f;
            }

            _sliderText.text = $"Hue: {_slider.value:F2}";

            _slider.onValueChanged.AddListener((v) => {
            _sliderText.text = $"Hue: {v:F2}";
            hueMap[auroraMat] = v;
            UpdateColor(v);
            });
        }
    }

    void resetSlider(){
        MaterialColors currentColors = originalColors[auroraMat];
        Color.RGBToHSV(currentColors.color1, out float originalHue, out _, out _);
        float currentHue = 0f;
        if(matSelector.currMat.HasProperty("_Color3")){
            Color.RGBToHSV(auroraMat.GetColor("_Color1"), out  currentHue, out _, out _);
        } else if(matSelector.currMat.HasProperty("_HueShift")){
            currentHue = auroraMat.GetFloat("_HueShift");
        }
        else {
            Color.RGBToHSV(auroraMat.GetColor("_MainColor"), out  currentHue, out _, out _);
        }

        if (Mathf.Approximately(currentHue, originalHue))
        {
            _slider.value = 0f;
            _sliderText.text = $"Hue: {0.0f:F2}";
        }
    }

    void UpdateColor(float hue){
        MaterialColors matColors = originalColors[auroraMat];
        if(matSelector.currMat.HasProperty("_Color3")){
            baseColor = auroraMat.GetColor("_Color1");
            secondColor = auroraMat.GetColor("_Color2");
            thirdColor = auroraMat.GetColor("_Color3");
            UpdateColorMulti(hue);
        } else if(matSelector.currMat.HasProperty("_HueShift")){
            auroraMat.SetFloat("_HueShift", hue);
        }
        else {
            mainColor = auroraMat.GetColor("_MainColor");
            secondaryColor = auroraMat.GetColor("_SecondaryColor");
            UpdateColorSingle(hue);
        }
    }

    void UpdateMaterialColors()
    {
        MaterialColors matColors = new MaterialColors();

        if (auroraMat.HasProperty("_Color3")) {
            matColors.color1 = auroraMat.GetColor("_Color1");
            matColors.color2 = auroraMat.GetColor("_Color2");
            matColors.color3 = auroraMat.GetColor("_Color3");
        } else if (auroraMat.HasProperty("_HueShift")) {
            matColors.color1 = new Color(auroraMat.GetFloat("_HueShift"), 0, 0);
        }
        else if (auroraMat.HasProperty("_BendStrength")) {
            matColors.color1 = auroraMat.GetColor("_MainColor");
            matColors.color2 = auroraMat.GetColor("_SecondaryColor");
        }
        else if (auroraMat.HasProperty("_MainColor")) {
            matColors.color1 = auroraMat.GetColor("_MainColor");
            matColors.color2 = auroraMat.GetColor("_SecondaryColor");
        }
        originalColors[auroraMat] = matColors;
    }

    void UpdateColorMulti(float hue)
    {
        Color.RGBToHSV(currentMatColors.color1, out float h1, out float s1, out float v1);
        float newH1 = Mathf.Repeat(h1 + hue, 1f);
        Color newColor1 = Color.HSVToRGB(newH1, s1, v1);

        Color.RGBToHSV(currentMatColors.color2, out float h2, out float s2, out float v2);
        float newH2 = Mathf.Repeat(h2 + hue, 1f);
        Color newColor2 = Color.HSVToRGB(newH2, s2, v2);

        Color.RGBToHSV(currentMatColors.color3, out float h3, out float s3, out float v3);
        float newH3 = Mathf.Repeat(h3 + hue, 1f);
        Color newColor3 = Color.HSVToRGB(newH3, s3, v3);

        auroraMat.SetColor("_Color1", newColor1);
        auroraMat.SetColor("_Color2", newColor2);
        auroraMat.SetColor("_Color3", newColor3);
    }

    void UpdateColorSingle(float hue)
    {
        Color.RGBToHSV(currentMatColors.color1, out float h1, out float s1, out float v1);
        float newH1 = Mathf.Repeat(h1 + hue, 1f);
        Color newColor1 = Color.HSVToRGB(newH1, s1, v1);

        Color.RGBToHSV(currentMatColors.color2, out float h2, out float s2, out float v2);
        float newH2 = Mathf.Repeat(h2 + hue, 1f);
        Color newColor2 = Color.HSVToRGB(newH2, s2, v2);

        auroraMat.SetColor("_MainColor", newColor1);
        auroraMat.SetColor("_SecondaryColor", newColor2);
    }
    
    
}
