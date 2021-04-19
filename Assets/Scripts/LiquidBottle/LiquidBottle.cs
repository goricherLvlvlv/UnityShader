using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class LiquidBottle : MonoBehaviour
{
    [Range(0, 1)]
    public float FillAmount;

    private MaterialPropertyBlock properties;
    private MaterialPropertyBlock Properties 
    {
        get
        {
            properties = properties ?? new MaterialPropertyBlock();
            return properties;
        }
    }

    private void Awake()
    {
    }

    private void Start()
    {
        SetFillAmount();
    }

    void Update()
    {
        if (transform.hasChanged)
        {
            SetHeight();
        }        
    }

    [ContextMenu("SetHeight")]
    public void SetHeight()
    {
        Properties.SetFloat("_Height", transform.position.y);
        if (TryGetComponent(out MeshRenderer component))
        {
            component.SetPropertyBlock(Properties);
        }
    }

    [ContextMenu("SetFillAmount")]
    public void SetFillAmount()
    {
        Properties.SetFloat("_FillAmount", -FillAmount * 3 + 2);
        if (TryGetComponent(out MeshRenderer component))
        {
            component.SetPropertyBlock(Properties);
        }
    }
}
