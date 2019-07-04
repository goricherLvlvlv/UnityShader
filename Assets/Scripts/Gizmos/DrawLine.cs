using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawLine : MonoBehaviour
{
    public Vector3 start;
    public Vector3 end;
    public Color c;

    void OnDrawGizmos()
    {
        Gizmos.color = c;
        Gizmos.DrawLine(start, end);

    }
}
