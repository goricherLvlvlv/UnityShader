using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class Controller : MonoBehaviour
{
    public static Controller Instance { get; private set; }

    public GameObject point;
    public GameObject redLine;
    public GameObject blackLine;

    [HideInInspector] public List<GameObject> points;
    [HideInInspector] public List<GameObject> lines;
    [HideInInspector] public List<GameObject> normals;

    void Awake()
    {
        Instance = this;
    }

    public void Clear()
    {
        ClearPoints();
        ClearLines();
        ClearNormals();
    }

    public void ClearPoints()
    {
        foreach (var p in points)
        {
            Destroy(p);
        }
        points.Clear();
    }

    public void ClearLines()
    {
        foreach (var l in lines)
        {
            Destroy(l);
        }
        lines.Clear();
    }

    public void ClearNormals()
    {
        foreach (var n in normals)
        {
            Destroy(n);
        }
        normals.Clear();
    }

    public void InitPoints(Vector3 worldPos)
    {
        var g = Instantiate(point, worldPos, Quaternion.identity);
        var pos = g.transform.position;
        pos.z = 0.0f;
        g.transform.position = pos;
        points.Add(g);
    }

    public Vector3 GetInterSection(Vector3 pos1, Vector3 dir1, Vector3 pos2, Vector3 dir2)
    {
        float k1 = dir1.y / dir1.x;
        float b1 = pos1.y - k1 * pos1.x;

        float k2 = dir2.y / dir2.x;
        float b2 = pos2.y - k2 * pos2.x;

        return new Vector3((b2 - b1) / (k1 - k2), (k1 * b2 - k2 * b1) / (k1 - k2), 0);
    }

    public void InitLines()
    {
        int cnt = points.Count;
        for (int i = 1; i < cnt; ++i)
        {
            var black = Instantiate(blackLine);
            black.GetComponent<DrawLine>().start = points[0].transform.position;
            black.GetComponent<DrawLine>().end = points[i].transform.position;
            lines.Add(black);

            Vector3 v = points[i].transform.position - points[0].transform.position;
            Vector3 n = Vector3.Cross(v, Vector3.forward).normalized;
            Vector3 center = (points[i].transform.position + points[0].transform.position) / 2;

            //if ((center - points[0]).magnitude > )
            //{
            //    continue;
            //}

            var red = Instantiate(redLine);
            red.GetComponent<DrawLine>().start = center + 20.0f * n;
            red.GetComponent<DrawLine>().end = center - 20.0f * n;
            normals.Add(red);
        }

    }

}
