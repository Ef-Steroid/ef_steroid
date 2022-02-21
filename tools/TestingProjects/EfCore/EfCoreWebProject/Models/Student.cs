namespace EfCoreWebProject.Models;

public class Student
{
    public int Id { get; set; }
    public string LastName { get; set; } = null!;
    public string FirstMidName { get; set; } = null!;

    public int Age { get; set; }
}
