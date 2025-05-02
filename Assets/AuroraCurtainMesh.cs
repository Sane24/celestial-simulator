using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class AuroraCurvedMesh : MonoBehaviour
{
    public int widthSegments = 100;
    public int heightSegments = 300;
    public float width = 100f;
    public float height = 50f;
    public float curvature = 6f;
    
    Mesh mesh;


    void Start()
    {   
        mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;


        GenerateMesh();
    }

    void GenerateMesh()
    {
        mesh.name = "Aurora Curtain";

        Vector3[] vertices = new Vector3[(widthSegments + 1) * (heightSegments + 1)];
        Vector2[] uvs = new Vector2[vertices.Length];
        int[] triangles = new int[widthSegments * heightSegments * 6];

        int vertIndex = 0;
        int triIndex = 0;

        for (int y = 0; y <= heightSegments; y++)
        {
            float v = (float)y / heightSegments;

            for (int x = 0; x <= widthSegments; x++)
            {
                float u = (float)x / widthSegments;

                // Arc shape: horizontal curve
                float angle = Mathf.Lerp(-Mathf.PI / 2f, Mathf.PI / 2f, u);
                float xPos = Mathf.Sin(angle) * curvature;
                float zPos = -Mathf.Cos(angle) * curvature + curvature;

                vertices[vertIndex] = new Vector3(xPos, v * height, zPos);
                uvs[vertIndex] = new Vector2(u, v);

                if (x < widthSegments && y < heightSegments)
                {
                    int i = vertIndex;
                    int nextRow = i + widthSegments + 1;

                    triangles[triIndex++] = i;
                    triangles[triIndex++] = nextRow;
                    triangles[triIndex++] = i + 1;

                    triangles[triIndex++] = i + 1;
                    triangles[triIndex++] = nextRow;
                    triangles[triIndex++] = nextRow + 1;
                }

                vertIndex++;
            }
        }

        mesh.vertices = vertices;
        mesh.uv = uvs;
        mesh.triangles = triangles;
        mesh.RecalculateBounds();
        mesh.RecalculateNormals();


        Debug.Log("Aurora curtain mesh generated: " + vertices.Length + " verts");
    }
}


