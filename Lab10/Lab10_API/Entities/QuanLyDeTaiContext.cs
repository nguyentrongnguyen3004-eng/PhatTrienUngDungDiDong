using Microsoft.EntityFrameworkCore;

namespace Lab10_API.Entities;

public class QuanLyDeTaiContext : DbContext
{
    public QuanLyDeTaiContext(DbContextOptions<QuanLyDeTaiContext> options)
        : base(options)
    {
    }

    public virtual DbSet<TblLoaiDeTai> TblLoaiDeTais { get; set; }
    public virtual DbSet<TblChuyenNganh> TblChuyenNganhs { get; set; }
    public virtual DbSet<TblDeTai> TblDeTais { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TblLoaiDeTai>(entity =>
        {
            entity.HasKey(e => e.MaLoai);
            entity.ToTable("tblLoaiDeTai");
        });

        modelBuilder.Entity<TblChuyenNganh>(entity =>
        {
            entity.HasKey(e => e.MaCN);
            entity.ToTable("tblChuyenNganh");
        });

        modelBuilder.Entity<TblDeTai>(entity =>
        {
            entity.HasKey(e => e.MaDeTai);
            entity.ToTable("tblDeTai");

            entity.HasOne(d => d.LoaiDeTai)
                .WithMany(p => p.TblDeTais)
                .HasForeignKey(d => d.MaLoai)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(d => d.ChuyenNganh)
                .WithMany(p => p.TblDeTais)
                .HasForeignKey(d => d.MaCN)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
